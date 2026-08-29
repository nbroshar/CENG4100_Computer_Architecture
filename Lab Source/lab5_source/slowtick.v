`timescale 1ns/1ps
// slowtick -- INFRASTRUCTURE (provided).  Runs on the 100 MHz clock and emits a
// one-cycle pulse `tick` every MAX cycles (~2 Hz), so the CPU steps slowly
// enough to WATCH on the LEDs.  We use a clock-ENABLE pulse, not a divided
// clock -- the FPGA-correct way (same idea as `en` in Lab 3).
module slowtick #(parameter MAX = 50_000_000)(input clk, output reg tick=0);
    reg [31:0] cnt = 0;
    always @(posedge clk)
        if (cnt == MAX-1) begin cnt <= 0; tick <= 1'b1; end
        else             begin cnt <= cnt + 1; tick <= 1'b0; end
endmodule
