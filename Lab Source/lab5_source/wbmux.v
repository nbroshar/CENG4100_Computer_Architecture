`timescale 1ns/1ps
module wbmux(input [3:0] alu_y, input [3:0] imm, input sel, output [3:0] wdata);
    assign wdata = sel ? imm : alu_y;
endmodule
