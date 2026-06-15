# Reference Solution — `popcount` (custom-0) extension

**Instructor-facing.** This solves the Week-2 custom-instruction exercise (the
"three touch points" / Rung-4 extension). Keep it out of the student-facing
base — the point of the exercise is for students to find these edits themselves.

It adds one instruction to the core:

```
pcnt rd, rs1     # rd = number of set bits in rs1  (custom-0 opcode 0x0B)
```

and shows how it is verified for free by the existing lockstep harness.

## What's here

| File | What it is |
|------|------------|
| `changes.diff` | The exact unified diffs for all five edits, across three files. |
| `pcnt_test.s` | A test program that exercises `pcnt` (and a few normal ops). |
| `pcnt_test.hex` | The same program, pre-assembled (needs the `asm.py` edit to regenerate). |
| `lockstep.log` | The captured run — proof the core and the golden model agree. |

## The five edits

Three are in the RTL (the student's job — the "three touch points"); two
complete the verification loop:

1. **`rtl/rv32i.v` · main decoder** — map opcode `0x0B` to control signals.
2. **`rtl/rv32i.v` · ALU decoder** — route the new `aluop` to a new ALU control code (this also makes the `2'd2` case explicit instead of `default`).
3. **`rtl/rv32i.v` · ALU** — implement the population count.
4. **`verif/rv32i_iss.py` · golden model** — the same behavior in one line, so the reference knows what "correct" is.
5. **`verif/asm.py` · assembler** — one line so `pcnt rd, rs1` encodes to the custom-0 opcode.

See `changes.diff` for the exact text of each.

## Apply and run

From the `rv32i_base/` root:

```bash
git apply solutions/popcount/changes.diff      # or: patch -p1 < solutions/popcount/changes.diff
cp solutions/popcount/pcnt_test.s verif/
cd verif
python3 asm.py pcnt_test.s -o program.hex
make sim
```

Expected (see `lockstep.log`):

```
lockstep OK: 6 instructions matched, halt at 0x00000014
test_lockstep.lockstep passed
TESTS=1 PASS=1 FAIL=0 SKIP=0
```

## The encoding

`pcnt` uses the RISC-V **custom-0** opcode `0b0001011` (`0x0B`) in an R-type-style
layout: `rd` and `rs1` are used, `funct3 = 000`, `rs2` is ignored. So
`pcnt x2, x1` assembles to `0x0000810b`. The test loads `x1 = 0xFF` (eight set
bits), so `pcnt x2, x1` produces `x2 = 8`.

## Why it verifies with no bespoke test

The lockstep harness compares the RTL core against the golden model on **every**
retired instruction — PC, register writeback, and stores. Once the model
implements `popcount` too (edit 4), any program containing `pcnt` checks the
hardware against the reference automatically. To stress it harder, drive many
random inputs through `pcnt` (extend `pcnt_test.s`, or generate programs with
`asm.py`); a single divergence is reported at the exact instruction.

## Teaching note

Reveal edits 1–3 only after students have attempted the RTL change themselves —
adding the instruction is the comprehension exercise. Edits 4–5 (model +
assembler) are the verification half and are reasonable to walk through together
as a code-along, since they're what makes the result trustworthy.
