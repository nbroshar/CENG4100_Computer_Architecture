`timescale 1ns/1ps
// ============================================================================
//  decoder -- turns one 16-bit INSTRUCTION into the control signals you set by
//  HAND in Lab 4.  This is the automatic control unit.
//    [15:12]=opcode  [9:8]=rd  [7:6]=rs1  [5:4]=rs2  [3:0]=imm
//    opcode: 1=LI  0=ADD  2=SUB  3=AND  4=OR  F=HALT
// ============================================================================
module decoder(
    input  [15:0] instr,
    output [1:0]  rd, rs1, rs2, alu_op,
    output [3:0]  imm,
    output        we, wbsel
);
    wire [3:0] opcode = instr[15:12];
    // TODO (behavior phase):
    // assign rd    = instr[9:8];
    // assign rs1   = instr[7:6];
    // assign rs2   = instr[5:4];
    // assign imm   = instr[3:0];
    // assign wbsel = (opcode == 4'd1);              // LI writes the immediate
    // assign we    = (opcode != 4'hF);              // all but HALT write a reg
    // assign alu_op = (opcode==4'd0)?2'd0 :         // ADD
    //                 (opcode==4'd2)?2'd1 :         // SUB
    //                 (opcode==4'd3)?2'd2 :         // AND
    //                 (opcode==4'd4)?2'd3 : 2'd0;   // OR / default
endmodule
