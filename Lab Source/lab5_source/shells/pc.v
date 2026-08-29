`timescale 1ns/1ps
// ============================================================================
//  pc -- the PROGRAM COUNTER.  It holds the address of the current instruction
//  and steps to the next one -- but only when `tick` pulses (so it advances at
//  the slow, watchable rate). 2 bits, so it wraps 3 -> 0 and the program loops.
//  This is the register from Lab 3, now counting on its own.
// ============================================================================
module pc(input clk, input rst, input tick, output reg [1:0] addr);
    // TODO (behavior phase):
    // always @(posedge clk)
    //   if (rst)       addr <= 2'd0;
    //   else if (tick) addr <= addr + 2'd1;
endmodule
