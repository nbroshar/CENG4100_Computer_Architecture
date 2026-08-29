# IP Integrator Lab 5 — Build a CPU (It Runs a Program By Itself)

The finale of the on-ramp. In Lab 4 YOU were the control unit, flipping switches
for each instruction. Now you add the two pieces that automate that -- a
**program counter** and an **instruction memory** to FETCH instructions, and a
**decoder** to turn each one into the control signals you used to set by hand.
Wire them to your Lab 4 datapath and the machine runs a stored program on its
own. That is a CPU.

```
 slowtick ─tick─► pc ─addr─► imem ─instr─► decoder ─┬─ rd  ─► regfile4 ─┬─► alu ─► wbmux ─► wdata ─┐
    ▲                 ▲                             ├─ rs1/rs2 ─►        │        ▲                 │
   clk               rst                            ├─ alu_op ──────────┼────────┘                 │
                                                    ├─ imm ────────────────► wbmux                 │
                                                    └─ we, wbsel ────────► regfile4 / wbmux         │
                                                          regfile4.wdata ◄──────────────────────────┘
```

## What you SEE on the board (free-running, ~2 Hz)
- **LD0–3 (wdata)** cycles **5 → 3 → 8** as the program runs: load 5, load 3, add.
- **LD14–15 (pc)** counts 0 → 1 → 2 → 3 and repeats (the program loops).
- **LD8–11 (alu_y)** shows the ALU output each step (8 during the ADD).
- Press **BTNC (rst)** to restart the program from instruction 0.

## The program (in imem, our 16-bit format)
`[15:12]=opcode [9:8]=rd [7:6]=rs1 [5:4]=rs2 [3:0]=imm` ; opcode 1=LI 0=ADD F=HALT
| addr | hex | meaning |
|------|-----|---------|
| 0 | 1105 | LI  r1, 5 |
| 1 | 1203 | LI  r2, 3 |
| 2 | 0360 | ADD r3, r1, r2 |
| 3 | F000 | HALT (then pc wraps to 0) |

## Files
- Provided: `alu.v`, `regfile4.v`, `wbmux.v` (your Lab 4 blocks), `slowtick.v`
  (makes it slow enough to watch), `imem.v` (the program).
- Shells to fill: `shells/pc.v` (the program counter), `shells/decoder.v`
  (instruction -> control signals).

## The bridge to the real core
Open `rv_top.v`. Every block here maps to a stage there:
**pc + imem = FETCH · decoder = DECODE · regfile4 + alu + wbmux = EXECUTE/WRITEBACK.**
You have now built a scale model of the RISC-V core -- next you start editing the
real thing.
