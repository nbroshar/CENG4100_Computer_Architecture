# IP Integrator Lab 1 — "Wiring Is Structure"

A first IP Integrator lab that makes the point students miss: **Verilog describes
hardware structure, not a program.** They build a tiny datapath — two operations
that compute **in parallel** and a mux that selects one — by wiring boxes on the
IP Integrator canvas, then read the Verilog Vivado generates from their picture
and see it is structural (module instances + wires). Then they put it on the
Basys 3 and watch both operations exist at once.

## The design
```
        a[3:0] ─┬────────────► op_and ─► and_y ─► in0 ┐
                │                                      ├─ mux2 ─► y[3:0] ─► LEDs
        b[3:0] ─┴────────────► op_or  ─► or_y  ─► in1 ┘        ▲
                                                        sel ───┘
```
`a`,`b` fan out to BOTH operation blocks (they run at the same time). `sel`
(SW15) chooses which result reaches the LEDs. sel=0 → AND, sel=1 → OR.

## Files
- `shells/` — student starting point: `op_and.v`, `op_or.v`, `mux2.v` as
  **port-only shells** (bodies are the behavior-phase TODO).
  (a structural sim that mirrors the block design; verifies AND=2, OR=14 for
  a=1010,b=0110 and shows both ops are always valid).
- `alu_slice.xdc` — Basys 3 pins for external ports a/b/sel/y.
- `create_bd.tcl` — fallback: builds the block design from the Tcl console.

## Pin map (a=1010, b=0110 → AND=0010=2, OR=1110=14)
| signal | bits | board |
|--------|------|-------|
| a | a[3:0] | SW0..SW3 |
| b | b[3:0] | SW4..SW7 |
| sel | sel | SW15 |
| y | y[3:0] | LD0..LD3 |

## Flow (Vivado 2026.1, part xc7a35tcpg236-1)
1. New RTL project; add the three `shells/*.v` as sources.
2. IP INTEGRATOR → Create Block Design.
3. Right-click canvas → Add Module → add op_and, op_or, mux2.
4. Ctrl+K → create external ports a[3:0], b[3:0], sel, y[3:0].
5. Wire per the diagram; Validate Design (F6).
6. Sources → right-click the .bd → Create HDL Wrapper (let Vivado manage).
7. Add `alu_slice.xdc`; Synthesize → Implement → Generate Bitstream → Program.

The behavior phase (fill the one-line bodies) comes after the structure phase in
the guided quiz.
