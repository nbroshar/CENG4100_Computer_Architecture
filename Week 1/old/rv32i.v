// ============================================================================
// rv32i.v  --  Single-cycle RV32I teaching core
// ============================================================================
// Read this file top to bottom. Leaf modules first (ALU, regfile, immgen,
// decoders), then the CPU that wires them together. The whole datapath and its
// control fit in your head; that is the point.
//
// EXTENSION POINTS are tagged  // <<< EXTEND .  Adding an instruction touches
// some subset of these tags and *nothing else*:
//     main_decoder  -- map a new opcode to control signals
//     alu_decoder   -- map a new (aluop,funct) to an ALU operation
//     alu           -- implement a new operation
//     immgen        -- add a new immediate format
//     writeback mux -- add a new result source
//
// IMPLEMENTED (complete, runnable RV32I core):
//   lui auipc jal jalr
//   beq bne blt bge bltu bgeu
//   lw sw
//   addi slti sltiu xori ori andi slli srli srai
//   add sub sll slt sltu xor srl sra or and
//
// DELIBERATELY LEFT OUT -- each gap is an architecture lesson, not busywork:
//   * sub-word memory (lb lh lbu lhu sb sh) -- byte lanes, sign/zero extend
//   * M extension (mul/div)                 -- multicycle control, stall/done
//   * system/fence (ecall ebreak fence csr) -- treated as nop for now
// ============================================================================


// ---------------------------------------------------------------------------
// ALU
//   ctrl legend: 0 ADD  1 SUB  2 AND  3 OR  4 XOR  5 SLL  6 SRL  7 SRA
//                8 SLT  9 SLTU                                   // <<< EXTEND
// ---------------------------------------------------------------------------
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  ctrl,
    output reg  [31:0] y
);
    wire signed [31:0] sa = a;
    wire signed [31:0] sb = b;
    always @(*) begin
        case (ctrl)
            4'd0:  y = a + b;
            4'd1:  y = a - b;
            4'd2:  y = a & b;
            4'd3:  y = a | b;
            4'd4:  y = a ^ b;
            4'd5:  y = a << b[4:0];
            4'd6:  y = a >> b[4:0];
            4'd7:  y = sa >>> b[4:0];
            4'd8:  y = (sa <  sb) ? 32'd1 : 32'd0;
            4'd9:  y = (a  <  b)  ? 32'd1 : 32'd0;
            // 4'd10: y = ... ;                                   // <<< EXTEND
            default: y = 32'd0;
        endcase
    end
endmodule


// ---------------------------------------------------------------------------
// Register file -- 2 async read ports, 1 sync write port, x0 hardwired to 0
// ---------------------------------------------------------------------------
module regfile (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  ra1, ra2, wa,
    input  wire [31:0] wd,
    output wire [31:0] rd1, rd2
);
    reg [31:0] r [0:31];
    integer i;
    initial for (i = 0; i < 32; i = i + 1) r[i] = 32'd0;
    always @(posedge clk)
        if (we && wa != 5'd0) r[wa] <= wd;
    assign rd1 = (ra1 == 5'd0) ? 32'd0 : r[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'd0 : r[ra2];
endmodule


// ---------------------------------------------------------------------------
// Immediate generator
//   immsrc: 0 I  1 S  2 B  3 U  4 J                             // <<< EXTEND
// ---------------------------------------------------------------------------
module immgen (
    input  wire [31:0] instr,
    input  wire [2:0]  immsrc,
    output reg  [31:0] imm
);
    always @(*) begin
        case (immsrc)
            3'd0: imm = {{20{instr[31]}}, instr[31:20]};                                   // I
            3'd1: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};                      // S
            3'd2: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B
            3'd3: imm = {instr[31:12], 12'b0};                                             // U
            3'd4: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J
            default: imm = 32'd0;
        endcase
    end
endmodule


// ---------------------------------------------------------------------------
// Main decoder -- opcode -> control signals
//   resultsrc: 0 ALU  1 mem  2 PC+4  3 imm(lui)                 // <<< EXTEND
//   aluop:     0 add   1 (branch helper)  2 from-funct
// ---------------------------------------------------------------------------
module main_decoder (
    input  wire [6:0] op,
    output reg        regwrite,
    output reg [2:0]  immsrc,
    output reg        alusrcA,   // 0 = rs1, 1 = pc (auipc)
    output reg        alusrcB,   // 0 = rs2, 1 = imm
    output reg        memwrite,
    output reg [1:0]  resultsrc,
    output reg        branch,
    output reg        jal,
    output reg        jalr,
    output reg [1:0]  aluop
);
    always @(*) begin
        // default: nop (also covers system/fence stubs)
        {regwrite, immsrc, alusrcA, alusrcB, memwrite,
         resultsrc, branch, jal, jalr, aluop} =
        {1'b0, 3'd0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 1'b0, 1'b0, 2'd0};
        case (op)
            7'b0110011: begin regwrite=1; alusrcB=0; aluop=2'd2; end                                 // R-type
            7'b0010011: begin regwrite=1; immsrc=0; alusrcB=1; aluop=2'd2; end                        // I-type ALU
            7'b0000011: begin regwrite=1; immsrc=0; alusrcB=1; resultsrc=1; aluop=2'd0; end           // lw
            7'b0100011: begin immsrc=1; alusrcB=1; memwrite=1; aluop=2'd0; end                        // sw
            7'b1100011: begin immsrc=2; branch=1; aluop=2'd1; end                                     // branches
            7'b1101111: begin regwrite=1; immsrc=4; resultsrc=2; jal=1; end                           // jal
            7'b1100111: begin regwrite=1; immsrc=0; alusrcB=1; resultsrc=2; jalr=1; aluop=2'd0; end    // jalr
            7'b0110111: begin regwrite=1; immsrc=3; resultsrc=3; end                                  // lui
            7'b0010111: begin regwrite=1; immsrc=3; alusrcA=1; alusrcB=1; aluop=2'd0; end              // auipc
            // 7'b0001011: ... custom-0 ...                                                            // <<< EXTEND
            default: ; // nop
        endcase
    end
endmodule


// ---------------------------------------------------------------------------
// ALU decoder -- (aluop, funct3, funct7b5, op5) -> ALU ctrl
// ---------------------------------------------------------------------------
module alu_decoder (
    input  wire       op5,       // opcode[5]: 1 for R-type
    input  wire [2:0] funct3,
    input  wire       funct7b5,  // instr[30]
    input  wire [1:0] aluop,
    output reg  [3:0] aluctrl
);
    always @(*) begin
        case (aluop)
            2'd0: aluctrl = 4'd0;             // add: load/store/jalr/auipc address
            2'd1: aluctrl = 4'd1;             // sub: reserved (branch compares live in the CPU)
            default: begin                    // 2'd2: decode from funct fields
                case (funct3)
                    3'b000: aluctrl = (op5 & funct7b5) ? 4'd1 : 4'd0; // sub : add
                    3'b001: aluctrl = 4'd5;                            // sll
                    3'b010: aluctrl = 4'd8;                            // slt
                    3'b011: aluctrl = 4'd9;                            // sltu
                    3'b100: aluctrl = 4'd4;                            // xor
                    3'b101: aluctrl = funct7b5 ? 4'd7 : 4'd6;          // sra : srl
                    3'b110: aluctrl = 4'd3;                            // or
                    3'b111: aluctrl = 4'd2;                            // and
                    default: aluctrl = 4'd0;                           // <<< EXTEND
                endcase
            end
        endcase
    end
endmodule


// ---------------------------------------------------------------------------
// CPU -- ties everything together. Memory lives outside (imem/dmem ports).
// ---------------------------------------------------------------------------
module rv32i_cpu (
    input  wire        clk,
    input  wire        reset,
    // instruction memory (read-only)
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_rdata,
    // data memory
    output wire [31:0] dmem_addr,
    output wire        dmem_we,
    output wire [31:0] dmem_wdata,
    input  wire [31:0] dmem_rdata
);
    // ---- Fetch ----
    reg  [31:0] pc;
    wire [31:0] pcplus4 = pc + 32'd4;
    assign imem_addr = pc;
    wire [31:0] instr = imem_rdata;

    // ---- Instruction fields ----
    wire [6:0] op       = instr[6:0];
    wire [2:0] funct3   = instr[14:12];
    wire       funct7b5 = instr[30];
    wire [4:0] a1       = instr[19:15];
    wire [4:0] a2       = instr[24:20];
    wire [4:0] rd       = instr[11:7];

    // ---- Control ----
    wire        regwrite, alusrcA, alusrcB, memwrite, branch, jal, jalr;
    wire [2:0]  immsrc;
    wire [1:0]  resultsrc, aluop;
    wire [3:0]  aluctrl;
    main_decoder MD (.op(op), .regwrite(regwrite), .immsrc(immsrc),
        .alusrcA(alusrcA), .alusrcB(alusrcB), .memwrite(memwrite),
        .resultsrc(resultsrc), .branch(branch), .jal(jal), .jalr(jalr), .aluop(aluop));
    alu_decoder AD (.op5(op[5]), .funct3(funct3), .funct7b5(funct7b5),
        .aluop(aluop), .aluctrl(aluctrl));

    // ---- Register file ----
    wire [31:0] rd1, rd2, result;
    regfile RF (.clk(clk), .we(regwrite), .ra1(a1), .ra2(a2), .wa(rd),
        .wd(result), .rd1(rd1), .rd2(rd2));

    // ---- Immediate ----
    wire [31:0] imm;
    immgen IG (.instr(instr), .immsrc(immsrc), .imm(imm));

    // ---- ALU ----
    wire [31:0] srcA = alusrcA ? pc  : rd1;
    wire [31:0] srcB = alusrcB ? imm : rd2;
    wire [31:0] aluresult;
    alu ALU (.a(srcA), .b(srcB), .ctrl(aluctrl), .y(aluresult));

    // ---- Data memory port ----
    assign dmem_addr  = aluresult;
    assign dmem_wdata = rd2;
    assign dmem_we    = memwrite;

    // ---- Writeback mux ----                                   // <<< EXTEND
    assign result = (resultsrc == 2'd0) ? aluresult  :
                    (resultsrc == 2'd1) ? dmem_rdata :
                    (resultsrc == 2'd2) ? pcplus4    :
                                          imm;        // lui

    // ---- Branch decision (comparisons, not the ALU) ----
    reg branch_taken;
    always @(*) begin
        case (funct3)
            3'b000:  branch_taken = (rd1 == rd2);                       // beq
            3'b001:  branch_taken = (rd1 != rd2);                       // bne
            3'b100:  branch_taken = ($signed(rd1) <  $signed(rd2));     // blt
            3'b101:  branch_taken = ($signed(rd1) >= $signed(rd2));     // bge
            3'b110:  branch_taken = (rd1 <  rd2);                       // bltu
            3'b111:  branch_taken = (rd1 >= rd2);                       // bgeu
            default: branch_taken = 1'b0;
        endcase
    end

    // ---- Next-PC ----
    wire [31:0] pctarget   = pc + imm;                 // branch / jal
    wire [31:0] jalrtarget = (rd1 + imm) & ~32'd1;     // jalr
    wire        take_branch = branch & branch_taken;
    always @(posedge clk) begin
        if (reset)                    pc <= 32'd0;
        else if (jalr)                pc <= jalrtarget;
        else if (jal | take_branch)   pc <= pctarget;
        else                          pc <= pcplus4;
    end
endmodule
