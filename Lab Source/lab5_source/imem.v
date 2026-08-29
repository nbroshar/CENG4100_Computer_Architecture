`timescale 1ns/1ps
// imem -- INSTRUCTION MEMORY (provided).  A tiny ROM holding our program in a
// 16-bit custom format:  [15:12]=opcode  [9:8]=rd  [7:6]=rs1  [5:4]=rs2  [3:0]=imm
//   opcode: 1=LI(load imm)  0=ADD  2=SUB  3=AND  4=OR  F=HALT
// The program is the same 5+3 story you ran by hand in Lab 4 -- now stored.
module imem(input [1:0] addr, output reg [15:0] instr);
    always @(*) case (addr)
        2'd0: instr = 16'h1105;  // LI  r1, 5
        2'd1: instr = 16'h1203;  // LI  r2, 3
        2'd2: instr = 16'h0360;  // ADD r3, r1, r2
        2'd3: instr = 16'hF000;  // HALT
        default: instr = 16'hF000;
    endcase
endmodule
