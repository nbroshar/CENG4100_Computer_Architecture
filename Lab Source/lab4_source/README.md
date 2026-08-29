# IP Integrator Lab 4 — Build a Datapath (You Are the Control Unit)

Labs 1–3 built the pieces: an ALU (compute), and a register (remember). This lab
adds the **register file** and wires everything into a real **datapath** — the
core of a single-cycle CPU. Then you execute one R-type instruction *by hand*,
setting the control signals yourself. The punchline: a processor's control unit
just generates these signals automatically from an instruction.

```
  rs1 ─►┌─────────┐ rdata1 ─►┌─────┐
  rs2 ─►│regfile4 │ rdata2 ─►│ alu │─ alu_y ─►┌───────┐
  rd  ─►│ 4 x 4b  │◄─ wdata ─────────────────│ wbmux │◄─ imm
  we  ─►│         │          alu_op ─►        └───────┘◄─ wbsel
  clk ─►└─────────┘
```

## Drive it by hand (each step = one "instruction")
| # | action | imm | rs1 | rs2 | rd | alu_op | wbsel | we |
|---|--------|-----|-----|-----|----|--------|-------|----|
| 1 | r1 = 5 (load) | 0101 | – | – | 01 | – | 1 | 1→0 |
| 2 | r2 = 3 (load) | 0011 | – | – | 10 | – | 1 | 1→0 |
| 3 | r1 + r2 (view) | – | 01 | 10 | – | 00 | – | 0 |
| 4 | r3 = r1+r2 (store) | – | 01 | 10 | 11 | 00 | 0 | 1→0 |
| 5 | read r3 | – | 11 | – | – | – | – | 0 |

"we 1→0" = flip SW13 up then back down to capture one value.
After step 3: LD8–11 (alu_y)=8, LD0–3 (rdata1)=5, LD4–7 (rdata2)=3.
After step 5: LD0–3 (rdata1)=8.

## Pin map
imm=SW0..3, rs1=SW4..5, rs2=SW6..7, rd=SW8..9, alu_op=SW10..11, wbsel=SW12,
we=SW13, clk=W5; rdata1=LD0..3, rdata2=LD4..7, alu_y=LD8..11.

## Files
- `alu.v` — your ALU block (provided).
- `shells/regfile4.v`, `shells/wbmux.v` — the new blocks to fill.
- `datapath.xdc`, `create_bd.tcl`.

## The bridge to the core
`regfile4` is `regfile.v` scaled to 4×4 (reg0 = x0). `wbsel` is the real core's
`mem_to_reg`-style write-back select. When you set rs1/rs2/rd/alu_op/we by hand,
you are doing the job of **control.v**, which decodes those signals from a 32-bit
instruction. Open `rv_top.v`: the five blocks are these same parts, wired the
same way — you have now built a datapath.
