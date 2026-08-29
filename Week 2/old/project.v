// ============================================================================
// project.v -- Tiny Tapeout wrapper for the RV32I teaching core (ASIC config)
// ============================================================================
// Adapts the core to a Tiny Tapeout tile's 8-in / 8-out / 8-bidir interface.
// A tile has no external memory, so the program lives in a small on-chip ROM
// (tt_rom) and data in a tiny on-chip RAM. The demo program sums 1..10 = 55
// and writes it to the output address; the result is read out one byte at a
// time over uo_out, selected by ui_in[1:0].
//
//   rst_n        active-low reset
//   ui_in[1:0]   select which byte of the 32-bit result to view
//   uo_out[7:0]  selected result byte
//   uio_out[0]   "done" -- the program has written its result
//
// Area note: the 32x32 register file dominates area. If this does not fit your
// tile budget, the first lever is RV32E (16 registers) -- a real ABI/area
// tradeoff worth discussing -- then trimming the data RAM. Check the LibreLane
// area report and set `tiles` in info.yaml accordingly.
// ============================================================================
`default_nettype none

module tt_um_rv32i (
    input  wire [7:0] ui_in,    // dedicated inputs
    output wire [7:0] uo_out,   // dedicated outputs
    input  wire [7:0] uio_in,   // bidirectional: input path
    output wire [7:0] uio_out,  // bidirectional: output path
    output wire [7:0] uio_oe,   // bidirectional: enable (1 = drive output)
    input  wire       ena,      // high when the design is selected
    input  wire       clk,
    input  wire       rst_n     // active-low reset
);
    wire reset = ~rst_n;

    // ---- CPU <-> memory wiring ----
    wire [31:0] imem_addr, imem_rdata;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire        dmem_we;

    rv32i_cpu cpu (
        .clk(clk), .reset(reset),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr), .dmem_we(dmem_we),
        .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata)
    );

    // ---- Instruction ROM (synthesizable case; regenerate from asm.py) ----
    tt_rom rom (.addr(imem_addr[7:2]), .data(imem_rdata));

    // ---- Tiny data RAM (16 words) + memory-mapped output capture ----
    localparam [31:0] OUT_ADDR = 32'h0000_0100;
    reg [31:0] ram [0:15];
    reg [31:0] out_reg;
    reg        done;

    assign dmem_rdata = ram[dmem_addr[5:2]];

    always @(posedge clk) begin
        if (reset) begin
            out_reg <= 32'd0;
            done    <= 1'b0;
        end else if (dmem_we) begin
            ram[dmem_addr[5:2]] <= dmem_wdata;
            if (dmem_addr == OUT_ADDR) begin
                out_reg <= dmem_wdata;
                done    <= 1'b1;
            end
        end
    end

    // ---- Output byte multiplexing ----
    wire [1:0] sel = ui_in[1:0];
    assign uo_out = (sel == 2'd0) ? out_reg[7:0]   :
                    (sel == 2'd1) ? out_reg[15:8]  :
                    (sel == 2'd2) ? out_reg[23:16] :
                                    out_reg[31:24];

    assign uio_out = {7'b0, done};   // uio[0] = done
    assign uio_oe  = 8'b0000_0001;   // uio[0] drives out, others are inputs

    // silence unused-signal warnings
    wire _unused = &{ena, uio_in, ui_in[7:2], 1'b0};
endmodule
