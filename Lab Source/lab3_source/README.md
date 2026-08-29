# IP Integrator Lab 3 — Add State (Clock + Register)

Combinational logic (Labs 1–2) always follows its inputs. This lab adds the
other half of digital design: **sequential logic** — a register that *captures*
a value on a clock edge and *holds* it. You see both at once on the board.

```
  a,b,alu_op ─► alu ─┬─► live[3:0] ─────────────► LD8..LD11   (always follows inputs)
                     └─► d ─► reg4 ─► q[3:0] ───► LD0..LD3    (holds until captured)
                  clk ─────────► reg4        en=SW15 ─► reg4
```

## What to watch on the board
- **LD8–LD11 (live)** = the ALU output, combinational — changes the instant you
  move a switch.
- **LD0–LD3 (q)** = the registered output — only updates while **en (SW15)** is
  up; with en down it **holds** its last value even as you change the switches.

Flip SW15 down, then change a/b/alu_op: the live LEDs move, the held LEDs don't.
That is the difference between logic that computes and logic that remembers.

## Pin map
| signal | bits | board |
|--------|------|-------|
| clk | clk | W5 (100 MHz) |
| a | a[3:0] | SW0..SW3 |
| b | b[3:0] | SW4..SW7 |
| alu_op | alu_op[1:0] | SW8..SW9 |
| en (capture) | en | SW15 |
| q (held) | q[3:0] | LD0..LD3 |
| live | live[3:0] | LD8..LD11 |

## Files
- `alu.v` — your Lab 2 ALU packaged as one reusable block (provided, complete).
- `shells/reg4.v` — the NEW sequential block to fill (the `always @(posedge clk)`).
- `reg.xdc`, `create_bd.tcl`.

## The key idea (sets up the whole datapath)
`reg4` is built with `always @(posedge clk) if (en) q <= d;`. That is the exact
pattern the core's **program counter** and **register file** use. Combinational
blocks (ALU) say *what to compute*; clocked registers say *what to remember*.
A processor is just many of each, wired together.
