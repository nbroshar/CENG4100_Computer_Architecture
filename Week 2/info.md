<!-- This is the datasheet rendered on the Tiny Tapeout website. -->

## How it works

This tile contains a small **single-cycle RV32I processor** with on-chip
program and data memory. The processor, its register file, ALU, decoders, and
datapath are the same teaching core students extend on the FPGA; this is the
area-optimized ASIC configuration of it.

On reset, the core begins executing a short program held in an on-chip ROM
(`tt_rom`). The demo program sums the integers 1 through 10 (= 55) and writes
the result to a memory-mapped output address (`0x100`), which latches it into an
output register and raises a **done** flag.

Because a tile has only eight output pins and the result is 32 bits wide, the
result is read back **one byte at a time**: `ui_in[1:0]` selects which byte
(0 = least significant) appears on `uo_out`.

## How to test

1. Hold `rst_n` low for a few clocks, then release it. The program runs in a
   handful of cycles.
2. Watch `uio_out[0]` (**done**) go high.
3. Read the 32-bit result by stepping `ui_in[1:0]` through 0, 1, 2, 3 and
   reading `uo_out` each time. Concatenating the four bytes (byte 0 = LSB) gives
   the result, which should be **55** (`0x00000037`).

To run a different program, edit the assembly, re-run the bundled assembler to
get a hex listing, regenerate `tt_rom.v` from it, and re-harden.

## External hardware

None. The demo board's inputs drive `ui_in` (the byte selector) and `rst_n`;
its outputs display `uo_out` and `uio_out[0]`. Switches and LEDs / the
seven-segment display on the demo PCB are sufficient.
