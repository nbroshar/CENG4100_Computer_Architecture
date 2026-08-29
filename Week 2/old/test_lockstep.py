"""
test_lockstep.py -- trace-before-modify harness (Week 2 comprehension gate).

Runs the RTL core and the golden ISS in lockstep and compares the commit stream
of every retired instruction:
    - PC
    - register writeback (rd, value)
    - memory store (address, value)

The first divergence is reported with the offending PC, which is exactly what a
student needs when an extension they added misbehaves. This is the template the
course reuses for every instruction they add: same harness, new program.

Swap-in Spike: replace `ISS(...)` with an adapter that yields the same commit
dicts parsed from `spike --log-commits`. The comparison logic below is unchanged.
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from rv32i_iss import ISS, load_hex


def val(sig):
    """int() a signal, failing loudly on X/Z so bugs surface instead of hiding."""
    b = sig.value
    if not b.is_resolvable:
        raise AssertionError(f"signal {sig._name} is X/Z: {b!r}")
    return int(b)


@cocotb.test()
async def lockstep(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    iss = ISS(load_hex("program.hex"))

    dut.reset.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0

    MAX = 5000
    for step in range(MAX):
        await ReadOnly()
        rtl_pc   = val(dut.CPU.pc)
        regwrite = val(dut.CPU.regwrite)
        rd       = val(dut.CPU.rd)
        result   = val(dut.CPU.result)
        mem_we   = val(dut.CPU.dmem_we)
        mem_addr = val(dut.CPU.dmem_addr)
        mem_wd   = val(dut.CPU.dmem_wdata)

        exp = iss.step()

        # PC
        assert rtl_pc == exp["pc"], \
            f"[{step}] PC mismatch: rtl={rtl_pc:#010x} iss={exp['pc']:#010x}"

        # register writeback
        rtl_rd  = rd if (regwrite and rd != 0) else None
        rtl_val = result if rtl_rd is not None else None
        assert (rtl_rd, rtl_val) == (exp["rd"], exp["rd_val"]), (
            f"[{step}] @pc {rtl_pc:#010x} writeback mismatch: "
            f"rtl(x{rtl_rd}<={rtl_val}) iss(x{exp['rd']}<={exp['rd_val']})")

        # memory store
        rtl_st = (mem_addr, mem_wd) if mem_we else None
        exp_st = (exp["mem_addr"], exp["mem_val"]) if exp["mem_addr"] is not None else None
        assert rtl_st == exp_st, (
            f"[{step}] @pc {rtl_pc:#010x} store mismatch: rtl={rtl_st} iss={exp_st}")

        await RisingEdge(dut.clk)

        if iss.pc == exp["pc"]:   # branch/jump to self => halt
            dut._log.info(f"lockstep OK: {step + 1} instructions matched, halt at {rtl_pc:#010x}")
            return

    raise AssertionError("did not reach halt within MAX instructions")
