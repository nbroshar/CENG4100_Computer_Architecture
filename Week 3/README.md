# Reference Solution — Sub-Word Memory (`lb lh lbu lhu sb sh`)

**Instructor-facing.** This solves the Week-3 extension. Keep it out of the
student base — finding these edits *is* the exercise.

It adds the six RV32I sub-word load/store instructions to the core:

```
lb  rd, off(rs1)   # load byte,      sign-extend
lh  rd, off(rs1)   # load halfword,  sign-extend
lbu rd, off(rs1)   # load byte,      zero-extend
lhu rd, off(rs1)   # load halfword,  zero-extend
sb  rs2, off(rs1)  # store low byte
sh  rs2, off(rs1)  # store low halfword
```

## What's here

| File | What it is |
|------|------------|
| `changes.diff` | Exact unified diffs for all four files. |
| `subword_test.s` | Coverage program: every form, all byte offsets, both halves. |
| `subword_test.hex` | The same program, pre-assembled. |
| `lockstep.log` | Captured run — 20 instructions matched, PASS. |

## The key idea

The opcodes `0x03` (loads) and `0x23` (stores) **already decode** in the base —
`lw`/`sw` work — so the main decoder needs no change. Sub-word access is purely a
datapath problem, and all of it lives in `rv32i.v`:

1. **Lane select.** `addr[1:0]` (`boff`) picks which byte/halfword of the
   32-bit word is in play.
2. **Extend (loads).** After extracting the lane, `funct3` chooses sign- vs
   zero-extension. A new `loaddata` block feeds the writeback mux instead of the
   raw `dmem_rdata`.
3. **Mask + merge (stores).** A word memory can't write a single byte, so a new
   `storedata` block does read-modify-write: take the current word
   (`dmem_rdata`), splice in the new byte/halfword, and write the merged word
   back. This is the `(word & ~mask) | new` idiom.

The data memory stays a plain word array; it is only **zero-initialized**
(`rv32i_sim_top.v`) so reads are deterministic and match the golden model's
zero-default. The golden ISS (`rv32i_iss.py`) and assembler (`asm.py`) get the
matching `funct3`-aware logic and the six mnemonics.

## The five edits

1. `rtl/rv32i.v` — `loaddata` (extract + extend) and `storedata` (mask + merge), plus wiring them into the writeback mux and `dmem_wdata`.
2. `rtl/rv32i_sim_top.v` — zero-initialize the data memory.
3. `verif/rv32i_iss.py` — `funct3`-aware loads (sign/zero extend) and stores (mask/merge).
4. `verif/asm.py` — the `lb/lh/lbu/lhu/sb/sh` mnemonics (a `LOADS`/`STORES` funct3 table).

## Apply and run

From the `rv32i_base/` root:

```bash
git apply solutions/subword-mem/changes.diff   # or: patch -p1 < solutions/subword-mem/changes.diff
cp solutions/subword-mem/subword_test.s verif/
cd verif
python3 asm.py subword_test.s -o program.hex
make sim
```

Expected (see `lockstep.log`):

```
lockstep OK: 20 instructions matched, halt at 0x0000004c
test_lockstep.lockstep passed
TESTS=1 PASS=1 FAIL=0 SKIP=0
```

## Why it still verifies with the same harness

Sub-word access is still single-cycle — one instruction retires per clock — so
the lockstep harness is unchanged. The only thing the golden model has to match
is the **commit representation**: a store reports the *byte* address and the
*merged word* it wrote (not a byte-granular write), so the model does the same
read-modify-write and reports the merged word. With the data memory
zero-initialized on both sides, RTL and model agree on every load and store.

## Teaching notes

- The store path is the conceptual heart: a byte store is really a word
  read-modify-write. Have students reason about why `sb` must read before it
  writes on a word-addressed memory.
- Real memories usually expose **byte write strobes** (e.g. AXI `WSTRB`) so the
  mask is applied at the memory instead of in the CPU. This solution does the
  merge in the CPU to keep the memory a plain word array — a good point of
  contrast to raise once students have the working version.
- Alignment is assumed (the test uses aligned halfwords). Misaligned-access
  traps are a natural extension question, not handled here.
