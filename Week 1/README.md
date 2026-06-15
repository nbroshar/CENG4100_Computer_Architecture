# RV32I Teaching Core

A small, complete, **legible** single-cycle RV32I processor — the brownfield base students read, run, and then extend. It is meant to be understood in full, not treated as a black box.

```
rv32i_base/
├── rtl/
│   ├── rv32i.v          # the CPU: ALU, regfile, immgen, decoders, datapath
│   └── rv32i_sim_top.v  # CPU + instruction ROM + data RAM + output port
├── test/
│   ├── test_cpu.py      # cocotb smoke test (template for student tests)
│   ├── Makefile         # `make` runs it under Icarus
│   └── program.hex      # sample program: computes 5 + 10, outputs 15
├── fpga/
│   └── basys3_top.v     # Basys 3 (Artix-7) wrapper, drives LEDs
└── README.md
```

## What's implemented

Complete, runnable RV32I:
`lui auipc jal jalr · beq bne blt bge bltu bgeu · lw sw · addi slti sltiu xori ori andi slli srli srai · add sub sll slt sltu xor srl sra or and`

## What's deliberately left out (these gaps *are* the lessons)

| Gap | What adding it teaches |
|-----|------------------------|
| Sub-word memory (`lb lh lbu lhu sb sh`) | Byte lanes, address alignment, sign- vs zero-extension on loads |
| `M` extension (`mul`, `div`, …) | Multicycle control: variable latency, a stall/done handshake, why the single-cycle assumption breaks |
| Custom functional unit (e.g. `popcount`) | The full decode→ALU→writeback path for one new operation, written from scratch |
| System/fence (`ecall ebreak fence csr`) | Currently decoded as `nop`; privilege/CSR is its own unit |

Adding sibling instructions that reuse an existing slot (e.g. `ori` when `andi` already exists) is intentionally *not* an exercise — it teaches nothing new. Every extension above forces a distinct part of the machine into view.

## Datapath at a glance

```
       +-------------------- PCSrc (pcplus4 / pctarget / jalrtarget) ----+
       |                                                                 |
   [ PC ] --addr--> [ IMEM ] --instr--> decoders -----> control signals  |
       |                          |                                      |
   pc+4 /pc+imm                fields                                     |
       |                  rs1 rs2 rd funct3/7                            |
       |                          |                                      |
       |                    [ REGFILE ] --rd1--> [srcA mux] --+          |
       |                          |  --rd2-------------------+ |         |
       |                    [ IMMGEN ] --imm--> [srcB mux] --|-+--> [ ALU ] --+
       |                                                     |              |
       |                                          rd2 --> [ DMEM ] <--addr--+
       |                                                     |
       +-- branch unit (rd1,rd2,funct3) --> branch_taken     |
                                                             v
                              [ writeback mux: ALU / mem / pc+4 / imm ] --> regfile.wd
```

Control signals (see `main_decoder`): `regwrite, immsrc, alusrcA, alusrcB, memwrite, resultsrc, branch, jal, jalr, aluop`. The ALU operation is derived separately in `alu_decoder`.

## Run the simulation

```
cd test
make            # Icarus + cocotb; expects program.hex in this dir
```
Expected: the smoke test passes with `cpu_out = 15`. A store to address `0x100` is captured into the `cpu_out` port and raises `out_valid` — that is the observation channel for both the testbench and the FPGA LEDs.

To run your own program, replace `program.hex` (one 32-bit instruction per line, hex) — generate it from assembly with the RISC-V GCC toolchain, or hand-assemble for tiny tests.

## On the Basys 3

Synthesize `fpga/basys3_top.v` together with `rtl/*.v`, add the standard Basys 3 XDC mapping `CLK100MHZ`, `sw[0]` (reset), and `led[15:0]`, and keep `program.hex` on the source path so the ROM initializes. `sw[0]` up = reset, down = run; the LEDs show the low 16 bits of the output value.

---

## Worked example: add a `popcount` instruction

Goal: `pcnt rd, rs1` — write the number of set bits in `rs1` into `rd`. We use the RISC-V *custom-0* opcode `0001011`, an R-type-style encoding (`rs2` unused), `funct3 = 000`.

It touches exactly **three** extension points and no datapath wiring:

**1. `main_decoder` — map the opcode.** Add a new `aluop = 2'd3` to mean "custom":
```verilog
7'b0001011: begin regwrite=1; alusrcB=0; aluop=2'd3; end   // custom-0: pcnt
```

**2. `alu_decoder` — map it to a new ALU control code.** Add a case for the new aluop:
```verilog
2'd3: aluctrl = 4'd10;   // popcount
```
(Change the outer `case (aluop)` so `2'd3` is handled explicitly rather than falling into the funct-decode `default`.)

**3. `alu` — implement the operation.** Add code `4'd10`:
```verilog
4'd10: begin : POPCOUNT
    integer k; reg [5:0] cnt;
    cnt = 0;
    for (k = 0; k < 32; k = k + 1) cnt = cnt + a[k];
    y = {26'd0, cnt};
end
```

That's the whole change: decode, ALU control, ALU op. `rd1` already arrives at the ALU's `a` input, the writeback mux already routes the ALU result to `rd`, and `rs2` is simply ignored. This is the pattern students imitate — and the reason the "add an instruction" task forces real understanding: you cannot place those three edits correctly without knowing how decode, control, and the datapath connect.

Then write a cocotb test (copy `test_cpu.py`) that loads a program using `pcnt` and checks the result against a reference popcount computed in Python — the start of differential testing against a golden model.
