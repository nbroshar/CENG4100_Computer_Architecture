`timescale 1ns/1ps
// ============================================================================
//  regfile4 -- a small REGISTER FILE: 4 registers x 4 bits.
//  Two read ports (async) and one write port (sync, on the clock edge).
//  Register 0 is hard-wired to 0 and ignores writes -- exactly like x0 in
//  RISC-V.  This is regfile.v from the core, scaled down to fit the board.
// ============================================================================
module regfile4(
    input        clk,
    input        we,              // write enable
    input  [1:0] raddr1, raddr2,  // two read addresses
    input  [1:0] waddr,           // write address
    input  [3:0] wdata,           // write data
    output [3:0] rdata1, rdata2   // two read results
);
    reg [3:0] rf [0:3];

    // TODO (behavior phase):
    // assign rdata1 = (raddr1 == 2'd0) ? 4'd0 : rf[raddr1];   // reg0 reads 0
    // assign rdata2 = (raddr2 == 2'd0) ? 4'd0 : rf[raddr2];
    // always @(posedge clk)
    //   if (we && waddr != 2'd0) rf[waddr] <= wdata;          // never write reg0
endmodule
