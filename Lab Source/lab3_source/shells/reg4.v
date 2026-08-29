`timescale 1ns/1ps
// ============================================================================
//  reg4 -- a 4-bit REGISTER (memory).  Unlike the ALU, it does NOT follow its
//  input continuously: it CAPTURES d into q only on a rising clock edge, and
//  only when en is high. Otherwise q HOLDS its value -- that is state.
//  This is the first sequential block you build; it is the same kind of
//  `always @(posedge clk)` that the core's PC and register file use.
// ============================================================================
module reg4(
    input        clk,
    input        en,       // capture-enable (hold when low)
    input  [3:0] d,        // data in (from the ALU)
    output reg [3:0] q     // data out (held)
);
    // TODO (behavior phase):
    // always @(posedge clk)
    //   if (en) q <= d;      // note: <= (non-blocking) for clocked logic
endmodule
