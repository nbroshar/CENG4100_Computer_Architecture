// ============================================================================
// rv32i_sim_top.v  --  simulation/FPGA wrapper: CPU + memories + output port
// ============================================================================
// Instruction ROM is loaded from program.hex (one 32-bit word per line, hex).
// A store to OUT_ADDR (0x100) is captured into cpu_out and raises out_valid --
// this is how the testbench (and the FPGA LEDs) observe a result.
// ============================================================================
module rv32i_sim_top (
    input  wire        clk,
    input  wire        reset,
    output reg  [31:0] cpu_out,
    output reg         out_valid
);
    localparam OUT_ADDR = 32'h0000_0100;

    wire [31:0] imem_addr, imem_rdata;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire        dmem_we;

    rv32i_cpu CPU (
        .clk(clk), .reset(reset),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr), .dmem_we(dmem_we),
        .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata)
    );

    // Instruction ROM (1024 words). Word-addressed by addr[11:2].
    reg [31:0] imem [0:1023];
    initial $readmemh("program.hex", imem);
    assign imem_rdata = imem[imem_addr[11:2]];

    // Data RAM (1024 words), async read for single-cycle loads.
    reg [31:0] dmem [0:1023];
    assign dmem_rdata = dmem[dmem_addr[11:2]];

    always @(posedge clk) begin
        if (reset) begin
            cpu_out   <= 32'd0;
            out_valid <= 1'b0;
        end else if (dmem_we) begin
            dmem[dmem_addr[11:2]] <= dmem_wdata;
            if (dmem_addr == OUT_ADDR) begin
                cpu_out   <= dmem_wdata;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
