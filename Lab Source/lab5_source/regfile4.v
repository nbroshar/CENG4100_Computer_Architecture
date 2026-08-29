`timescale 1ns/1ps
module regfile4(input clk, input we, input [1:0] raddr1, raddr2, input [1:0] waddr,
                input [3:0] wdata, output [3:0] rdata1, rdata2);
    reg [3:0] rf [0:3]; integer i; initial for(i=0;i<4;i=i+1) rf[i]=4'd0;
    assign rdata1 = (raddr1==2'd0)?4'd0:rf[raddr1];
    assign rdata2 = (raddr2==2'd0)?4'd0:rf[raddr2];
    always @(posedge clk) if (we && waddr!=2'd0) rf[waddr] <= wdata;
endmodule
