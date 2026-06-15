"""
test_cpu.py -- cocotb smoke test for the RV32I teaching core.

Runs program.hex (computes 5 + 10 and stores 15 to the output address) and
checks that the core produces 15. This is the template students copy to turn
each new instruction into a self-checking, differential test against a golden
model (Spike) later in the course.
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def smoke(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # reset
    dut.reset.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0

    # run until the core writes the output port (or we give up)
    for _ in range(50):
        await RisingEdge(dut.clk)
        if dut.out_valid.value == 1:
            break

    assert dut.out_valid.value == 1, "CPU never wrote the output address"
    got = dut.cpu_out.value.integer
    assert got == 15, f"expected 15, got {got}"
    dut._log.info(f"PASS: cpu_out = {got}")
