#!/usr/bin/env python3
"""
rv32i_iss.py -- a small, readable RV32I instruction-set simulator used as the
golden model for lockstep verification.

It mirrors exactly the instruction subset the teaching core implements, so the
RTL and this model should agree, instruction by instruction, on:
    - the PC of each retired instruction
    - any register writeback (rd, value)
    - any memory store (address, value)

That commit stream is what the cocotb harness compares. To use Spike as the
golden model instead, replace `ISS` with an adapter that parses Spike's
`--log-commits` output into the same commit dicts (see verif/README.md).
"""
MASK = 0xFFFFFFFF


def sgn(v):
    v &= MASK
    return v - (1 << 32) if v & 0x80000000 else v


class ISS:
    def __init__(self, imem, dmem=None):
        # imem/dmem: dict of {word_index: word}; word_index = byte_addr >> 2
        self.x = [0] * 32
        self.pc = 0
        self.imem = dict(imem)
        self.dmem = dict(dmem or {})

    def _ld(self, addr):
        return self.dmem.get((addr & MASK) >> 2, 0) & MASK

    def _st(self, addr, val):
        self.dmem[(addr & MASK) >> 2] = val & MASK

    def step(self):
        instr = self.imem.get(self.pc >> 2, 0) & MASK
        pc = self.pc
        c = {"pc": pc, "instr": instr, "rd": None, "rd_val": None,
             "mem_addr": None, "mem_val": None}

        op  = instr & 0x7F
        rd  = (instr >> 7) & 0x1F
        f3  = (instr >> 12) & 0x7
        rs1 = (instr >> 15) & 0x1F
        rs2 = (instr >> 20) & 0x1F
        f7  = (instr >> 25) & 0x7F
        a, b = self.x[rs1] & MASK, self.x[rs2] & MASK

        # immediates
        immI = sgn(instr >> 20) if instr & 0x80000000 else (instr >> 20)
        immI = sgn((instr >> 20) | (0xFFFFF000 if instr & 0x80000000 else 0))
        immS = sgn(((instr >> 25) << 5 | ((instr >> 7) & 0x1F)) |
                   (0xFFFFF000 if instr & 0x80000000 else 0))
        immB = sgn((((instr >> 31) & 1) << 12) | (((instr >> 7) & 1) << 11) |
                   (((instr >> 25) & 0x3F) << 5) | (((instr >> 8) & 0xF) << 1) |
                   (0xFFFFE000 if instr & 0x80000000 else 0))
        immU = instr & 0xFFFFF000
        immJ = sgn((((instr >> 31) & 1) << 20) | (((instr >> 12) & 0xFF) << 12) |
                   (((instr >> 20) & 1) << 11) | (((instr >> 21) & 0x3FF) << 1) |
                   (0xFFE00000 if instr & 0x80000000 else 0))

        nextpc = (pc + 4) & MASK

        def wb(val):
            c["rd"], c["rd_val"] = rd, val & MASK

        if op == 0x33:        # R-type
            sh = b & 0x1F
            r = {0x0: (a - b if (f7 == 0x20) else a + b),
                 0x1: a << sh, 0x2: 1 if sgn(a) < sgn(b) else 0,
                 0x3: 1 if a < b else 0, 0x4: a ^ b,
                 0x5: (sgn(a) >> sh) if (f7 == 0x20) else (a >> sh),
                 0x6: a | b, 0x7: a & b}[f3]
            wb(r)
        elif op == 0x13:      # I-type ALU
            sh = immI & 0x1F
            r = {0x0: a + immI, 0x2: 1 if sgn(a) < immI else 0,
                 0x3: 1 if a < (immI & MASK) else 0, 0x4: a ^ (immI & MASK),
                 0x6: a | (immI & MASK), 0x7: a & (immI & MASK),
                 0x1: a << sh,
                 0x5: (sgn(a) >> sh) if (f7 == 0x20) else (a >> sh)}[f3]
            wb(r)
        elif op == 0x03:      # lw
            addr = (a + immI) & MASK
            wb(self._ld(addr))
        elif op == 0x23:      # sw
            addr = (a + immS) & MASK
            self._st(addr, b)
            c["mem_addr"], c["mem_val"] = addr, b & MASK
        elif op == 0x63:      # branches
            take = {0x0: a == b, 0x1: a != b, 0x4: sgn(a) < sgn(b),
                    0x5: sgn(a) >= sgn(b), 0x6: a < b, 0x7: a >= b}[f3]
            if take:
                nextpc = (pc + immB) & MASK
        elif op == 0x6F:      # jal
            wb(nextpc)
            nextpc = (pc + immJ) & MASK
        elif op == 0x67:      # jalr
            wb(nextpc)
            nextpc = (a + immI) & ~1 & MASK
        elif op == 0x37:      # lui
            wb(immU)
        elif op == 0x17:      # auipc
            wb((pc + immU) & MASK)
        # else: nop (system/fence stubs)

        if rd == 0:
            c["rd"], c["rd_val"] = None, None  # x0 never observably written
        elif c["rd"] is not None:
            self.x[rd] = c["rd_val"]
        self.x[0] = 0
        self.pc = nextpc
        return c


def load_hex(path):
    mem = {}
    for i, line in enumerate(open(path)):
        line = line.strip()
        if line:
            mem[i] = int(line, 16) & MASK
    return mem
