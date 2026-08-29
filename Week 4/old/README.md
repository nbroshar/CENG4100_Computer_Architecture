# Reference Solution — Custom Functional Unit: `clz` (count leading zeros)

**Instructor-facing.** This solves the Week-4 extension (Rung 3). Keep it out of
the student base — designing the unit *is* the exercise.

It adds a count-leading-zeros instruction, implemented as a **separate functional
unit module** wired into the datapath:

```
clz rd, rs1     # rd = number of leading zero bits in rs1 (0..32)
```

`clz` is a real RISC-V `Zbb` instruction; here it rides the **custom-0** opcode
(`0x0B`, funct3 `001`) so it doesn't collide with the base ISA.

## What's here

| File | What it is |
|------|------------|
| `changes.diff` | Exact unified diffs for all three files. |
| `clz_test.s` | A directed test: clz of 1, `0x80000000`, `0x00010000`, 255, 0, 16. |
| `clz_test.hex` | The same program, pre-assembled. |
| `lockstep.log` | Captured run — 15 instructions matched, PASS. |

## What makes this different from the Week-2 warm-up

The popcount warm-up (Rung 1) was a new `case` arm *inside* the ALU — a one-line
operation reusing the existing result path. This is the next step up: a **unit of
its own**.

1. **A standalone module.** `clz32` is written from scratch — a priority encoder
   that scans from the MSB down for the first set bit. This is the P&H Ch-3
   "design arithmetic/bit hardware" beat.
2. **Operand routing.** The CPU taps `rd1` straight into the unit
   (`clz32 CLZ (.x(rd1), ...)`) rather than going through the ALU's `srcA/srcB`.
3. **Result selection.** A new control bit, `fusel`, comes out of the main
   decoder. When set, the writeback's ALU-result input is driven by the unit's
   output instead of the ALU:
   `alumux = fusel ? fu_result : aluresult`.

That `separate unit + select signal` structure is deliberate: it's exactly what
Week 5's multicycle multiply extends, by adding a `done`/stall handshake to a unit
that can no longer finish in one cycle.

## The three edits

1. `rtl/rv32i.v` — the `clz32` module; a `fusel` control out of `main_decoder`; the unit instantiation, `fu_result`, and the `alumux` select feeding the writeback.
2. `verif/rv32i_iss.py` — the golden model: `wb(32 - a.bit_length())` (which yields 32 for `a == 0`).
3. `verif/asm.py` — the `clz rd, rs1` mnemonic (custom-0, funct3 `001`).

## Apply and run

From the `rv32i_base/` root:

```bash
git apply solutions/clz-unit/changes.diff   # or: patch -p1 < solutions/clz-unit/changes.diff
cp solutions/clz-unit/clz_test.s verif/
cd verif
python3 asm.py clz_test.s -o program.hex
make sim
```

Expected (see `lockstep.log`):

```
lockstep OK: 15 instructions matched, halt at 0x00000038
test_lockstep.lockstep passed
TESTS=1 PASS=1 FAIL=0 SKIP=0
```

## The unit, in one breath

`clz` counts the zeros above the most-significant set bit: if the highest set bit
is at index *k*, then `clz = 31 - k`; and `clz(0) = 32`. The golden model says the
same thing as `32 - x.bit_length()`. The hardware is a priority scan from bit 31
down — a clean from-scratch combinational design.

## Teaching notes

- The `min/max` option from the curriculum is a good alternative or a second unit:
  same integration pattern, but the unit is a comparator + mux and reads *two*
  operands — a nice contrast with clz's single operand.
- Push students on **why this is a separate unit and popcount wasn't**. The answer
  ("so Week 5 can make it multicycle without touching the ALU") is the throughline.
- For stronger verification, replace the directed test with a randomized
  differential loop: drive thousands of random `rs1` values and compare `clz`
  against `32 - x.bit_length()`. Directed catches the boundaries (0, 1,
  `0x80000000`); random catches the rest.
