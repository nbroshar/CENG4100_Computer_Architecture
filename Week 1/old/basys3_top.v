// ============================================================================
// basys3_top.v  --  Basys 3 (Artix-7 XC7A35T) wrapper
// ============================================================================
// Minimal "it runs on the board" wrapper: the low 16 bits of the CPU output
// drive the LEDs, and out_valid lights LED15-as-done via sw-controlled reset.
//
//   sw[0]  -> reset (slide up to reset, down to run)
//   led    -> low 16 bits of the last value written to the output address
//
// Add a UART or seven-seg display here when you want richer I/O. Constraints:
// map CLK100MHZ, sw[0], and led[15:0] in the standard Basys 3 XDC, and make
// sure program.hex is on the synthesis source path so $readmemh inits the ROM.
//
// Note: this runs the core at the full 100 MHz. If timing does not close on
// the single-cycle critical path (ALU + memory in one cycle), add a clock
// divider here and feed the slower clock to the core -- a good lab discussion.
// ============================================================================
module basys3_top (
    input  wire        CLK100MHZ,
    input  wire [15:0] sw,
    output wire [15:0] led
);
    wire        reset = sw[0];
    wire [31:0] cpu_out;
    wire        out_valid;

    rv32i_sim_top CORE (
        .clk(CLK100MHZ),
        .reset(reset),
        .cpu_out(cpu_out),
        .out_valid(out_valid)
    );

    assign led = cpu_out[15:0];
endmodule
