`timescale 1ns/1ps
module alu(input [3:0] a, input [3:0] b, input [1:0] alu_op, output reg [3:0] y);
    always @(*) case (alu_op)
        2'd0: y=a+b; 2'd1: y=a-b; 2'd2: y=a&b; 2'd3: y=a|b; default: y=a+b;
    endcase
endmodule
