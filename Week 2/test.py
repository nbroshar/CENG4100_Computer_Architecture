"""
Tiny Tapeout test for tt_um_rv32i.

Resets the chip, lets the on-chip program run (sum 1..10 = 55), waits for the
done flag on uio_out[0], then reads the 32-bit result one byte at a time over
uo_out using the ui_in[1:0] byte selector, and checks it equals 55.
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer


async def read_byte(dut, sel):
    dut.ui_in.value = sel & 0x3
    await Timer(1, unit="ns")
    return int(dut.uo_out.value)


@cocotb.test()
async def test_rv32i(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # run until the program signals done (uio_out[0]), with a timeout
    for _ in range(200):
        await RisingEdge(dut.clk)
        if int(dut.uio_out.value) & 0x1:
            break
    assert int(dut.uio_out.value) & 0x1, "program never asserted done"

    # reconstruct the 32-bit result from four byte reads
    result = 0
    for i in range(4):
        result |= (await read_byte(dut, i)) << (8 * i)

    assert result == 55, f"expected 55, got {result}"
    dut._log.info(f"PASS: result = {result}")
