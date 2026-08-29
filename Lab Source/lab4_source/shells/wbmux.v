`timescale 1ns/1ps
// ============================================================================
//  wbmux -- the write-back source mux: what value gets stored into a register?
//  sel=0 -> the ALU result (compute and store)
//  sel=1 -> an immediate from the switches (seed a register with a constant)
// ============================================================================
module wbmux(
    input  [3:0] alu_y,
    input  [3:0] imm,
    input        sel,
    output [3:0] wdata
);
    // TODO (behavior phase):  assign wdata = sel ? imm : alu_y;
endmodule
