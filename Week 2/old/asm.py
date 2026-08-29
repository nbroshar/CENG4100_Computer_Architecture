#!/usr/bin/env python3
"""
asm.py -- a tiny two-pass assembler for the RV32I teaching subset.

Enough to author test programs by hand without encoding errors. Supports the
instructions the base core implements, labels, and a few pseudo-ops
(li for small immediates, mv, nop, j). Output is program.hex (one 32-bit word
per line), the format rv32i_sim_top.v expects.

Usage:
    python3 asm.py prog.s -o program.hex
"""
import sys, re

ABI = {
    "zero":0,"ra":1,"sp":2,"gp":3,"tp":4,"t0":5,"t1":6,"t2":7,
    "s0":8,"fp":8,"s1":9,"a0":10,"a1":11,"a2":12,"a3":13,"a4":14,"a5":15,
    "a6":16,"a7":17,"s2":18,"s3":19,"s4":20,"s5":21,"s6":22,"s7":23,
    "s8":24,"s9":25,"s10":26,"s11":27,"t3":28,"t4":29,"t5":30,"t6":31,
}
def reg(t):
    t = t.strip()
    if t in ABI: return ABI[t]
    if re.fullmatch(r"x\d+", t): return int(t[1:])
    raise ValueError(f"bad register {t!r}")

def imm(t, labels=None, pc=None, rel=False):
    t = t.strip()
    if labels is not None and t in labels:
        return labels[t] - pc if rel else labels[t]
    return int(t, 0)

# (funct7, funct3) for R-type; funct3 for I/B; opcodes
R = {"add":(0x00,0x0),"sub":(0x20,0x0),"sll":(0x00,0x1),"slt":(0x00,0x2),
     "sltu":(0x00,0x3),"xor":(0x00,0x4),"srl":(0x00,0x5),"sra":(0x20,0x5),
     "or":(0x00,0x6),"and":(0x00,0x7)}
I = {"addi":0x0,"slti":0x2,"sltiu":0x3,"xori":0x4,"ori":0x6,"andi":0x7,
     "slli":0x1,"srli":0x5,"srai":0x5}
B = {"beq":0x0,"bne":0x1,"blt":0x4,"bge":0x5,"bltu":0x6,"bgeu":0x7}

def enc_r(rd,rs1,rs2,f7,f3): return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x33
def enc_i(rd,rs1,im,f3,op=0x13): return ((im&0xFFF)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def enc_s(rs1,rs2,im,f3):
    im&=0xFFF; return ((im>>5)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|((im&0x1F)<<7)|0x23
def enc_b(rs1,rs2,im,f3):
    im&=0x1FFF
    return (((im>>12)&1)<<31)|(((im>>5)&0x3F)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|\
           (((im>>1)&0xF)<<8)|(((im>>11)&1)<<7)|0x63
def enc_u(rd,im,op): return ((im&0xFFFFF)<<12)|(rd<<7)|op
def enc_j(rd,im):
    im&=0x1FFFFF
    return (((im>>20)&1)<<31)|(((im>>1)&0x3FF)<<21)|(((im>>11)&1)<<20)|\
           (((im>>12)&0xFF)<<12)|(rd<<7)|0x6F

def assemble(text):
    lines, labels, pc = [], {}, 0
    # pass 1: collect labels, normalize lines
    norm = []
    for raw in text.splitlines():
        s = raw.split("#")[0].strip()
        if not s: continue
        while ":" in s:
            lab, _, rest = s.partition(":")
            labels[lab.strip()] = pc
            s = rest.strip()
            if not s: break
        if not s: continue
        norm.append((pc, s)); pc += 4
    # pass 2: encode
    out = []
    for pc, s in norm:
        m = re.match(r"(\S+)\s*(.*)", s)
        op = m.group(1).lower()
        args = [a.strip() for a in m.group(2).split(",")] if m.group(2) else []
        if op == "nop": out.append(enc_i(0,0,0,0x0)); continue
        if op == "mv":  out.append(enc_i(reg(args[0]),reg(args[1]),0,0x0)); continue
        if op == "li":  out.append(enc_i(reg(args[0]),0,imm(args[1]),0x0)); continue
        if op == "j":   out.append(enc_j(0, imm(args[0],labels,pc,rel=True))); continue
        if op in R:
            f7,f3 = R[op]; out.append(enc_r(reg(args[0]),reg(args[1]),reg(args[2]),f7,f3)); continue
        if op in I:
            f3 = I[op]
            iv = imm(args[2])
            if op == "srai": iv = (iv & 0x1F) | 0x400  # set funct7 bit 5
            out.append(enc_i(reg(args[0]),reg(args[1]),iv,f3)); continue
        if op == "lw":
            off, base = parse_mem(args[1]); out.append(enc_i(reg(args[0]),base,off,0x2,op=0x03)); continue
        if op == "sw":
            off, base = parse_mem(args[1]); out.append(enc_s(base,reg(args[0]),off,0x2)); continue
        if op in B:
            out.append(enc_b(reg(args[0]),reg(args[1]),imm(args[2],labels,pc,rel=True),B[op])); continue
        if op == "lui":   out.append(enc_u(reg(args[0]),imm(args[1]),0x37)); continue
        if op == "auipc": out.append(enc_u(reg(args[0]),imm(args[1]),0x17)); continue
        if op == "jal":
            if len(args)==1: rd,tgt=1,args[0]
            else: rd,tgt=reg(args[0]),args[1]
            out.append(enc_j(rd, imm(tgt,labels,pc,rel=True))); continue
        if op == "jalr":
            off, base = parse_mem(args[1]) if "(" in args[1] else (0,reg(args[1]))
            out.append(enc_i(reg(args[0]),base,off,0x0,op=0x67)); continue
        raise ValueError(f"unknown instruction: {s!r}")
    return out

def parse_mem(t):
    m = re.match(r"(-?\w+)\((\w+)\)", t.strip())
    return int(m.group(1),0), reg(m.group(2))

if __name__ == "__main__":
    src = sys.argv[1]
    outp = "program.hex"
    if "-o" in sys.argv: outp = sys.argv[sys.argv.index("-o")+1]
    words = assemble(open(src).read())
    with open(outp, "w") as f:
        for w in words: f.write(f"{w & 0xFFFFFFFF:08x}\n")
    print(f"assembled {len(words)} instructions -> {outp}")
