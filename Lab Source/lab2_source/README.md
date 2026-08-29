# IP Integrator Lab 2 — Build an ALU

Same diagram-first flow as Lab 1, scaled up to a real **4-operation ALU**. Four
operation blocks compute **in parallel**; an opcode-driven mux selects one
result for the LEDs. This is `alu.v` in miniature.

```
   a[3:0] ─┬─► op_add ─► ADD ─► in0 ┐
           ├─► op_sub ─► SUB ─► in1 ├─ alu_mux ─► y[3:0] ─► LEDs
   b[3:0] ─┼─► op_and ─► AND ─► in2 ┤     ▲
           └─► op_or  ─► OR  ─► in3 ┘     │
                                  alu_op ─┘
```

## Opcode (alu_op)  ·  test vector a=0101 (5), b=0011 (3)
| alu_op | op  | y (bin) | y (dec) |
|--------|-----|---------|---------|
| 00 | ADD | 1000 | 8 |
| 01 | SUB | 0010 | 2 |
| 10 | AND | 0001 | 1 |
| 11 | OR  | 0111 | 7 |

## Pin map (Basys 3)
| signal | bits | board |
|--------|------|-------|
| a | a[3:0] | SW0..SW3 |
| b | b[3:0] | SW4..SW7 |
| alu_op | alu_op[1:0] | SW8..SW9 |
| y | y[3:0] | LD0..LD3 |

## Files
- `shells/` — student start: op_add, op_sub, op_and, op_or, alu_mux (port-only).
  (op_and/op_or are the same blocks you built in Lab 1.)
  four units live at once).
- `alu.xdc`, `create_bd.tcl`.

## Flow (part xc7a35tcpg236-1)
Add the five shells → Create Block Design `alu` → Add Module (×5) → Ctrl+K ports
a[3:0], b[3:0], alu_op[1:0], y[3:0] → wire per the diagram → Validate → Create
HDL Wrapper → add `alu.xdc` → Synthesize → Implement → Bitstream → Program.

## Extension (Verilog refresh + Week-5 preview)
Add a 5th operation (XOR, alu_op=4): add an `op_xor` block, widen `alu_mux` to
in4 + `sel[2:0]` (add `3'd4: y = in4;`), and widen `alu_op` to 3 bits (SW10).
That "add a block + widen the mux + widen the select" is exactly how you add an
instruction to the real core later.
