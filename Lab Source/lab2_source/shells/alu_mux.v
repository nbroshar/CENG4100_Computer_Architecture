`timescale 1ns/1ps
// ============================================================================
//  alu_mux -- the selector at the heart of the ALU.  Four operation results
//  come in (in0..in3); alu_op chooses which one leaves as y.  The case below
//  IS the "select" -- the same shape you'll later see in the core's alu.v.
//    sel 0 -> ADD (in0)   1 -> SUB (in1)   2 -> AND (in2)   3 -> OR (in3)
// ============================================================================
module alu_mux(
    input  [3:0] in0, in1, in2, in3,
    input  [1:0] sel,
    output reg [3:0] y
);
    // TODO (behavior):
    // always @(*) case (sel)
    //   2'd0: y = in0;   // ADD
    //   2'd1: y = in1;   // SUB
    //   2'd2: y = in2;   // AND
    //   2'd3: y = in3;   // OR
    //   default: y = in0;
    // endcase
endmodule
