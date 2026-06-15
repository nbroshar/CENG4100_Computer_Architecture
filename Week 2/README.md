# Verification harness — trace before modify

The Week-2 comprehension gate, and the template students reuse for every
instruction they add. It runs the RTL core and a golden model in **lockstep**
and compares the commit stream of every retired instruction:

- the **PC** of the instruction,
- any **register writeback** (`rd`, value),
- any **memory store** (address, value).

The first divergence is reported with the offending PC and both values — which
is exactly the information a student needs when an extension misbehaves.

```
verif/
├── asm.py            # tiny RV32I assembler (author programs without hand-encoding)
├── rv32i_iss.py      # golden model: a small, readable RV32I interpreter
├── test_lockstep.py  # cocotb harness: RTL vs golden model, instruction by instruction
├── sanity.s          # coverage program: hits every implemented datapath path
└── Makefile
```

## Run it

```
cd verif
make prog     # assemble sanity.s -> program.hex
make sim      # run the lockstep comparison under Icarus + cocotb
```

Expected: `lockstep OK: N instructions matched, halt at 0x...`. The harness
halts when the program branches/jumps to itself (the `j done` idiom).

To check your own program, write it in `.s`, `python3 asm.py yours.s -o program.hex`,
and `make sim`.

## It actually catches bugs

Injecting a fault into the RTL (e.g. making `sub` compute `a + b`) produces:

```
[3] @pc 0x0000000c writeback mismatch: rtl(x4<=107) iss(x4<=93)
```

— the exact instruction and the exact wrong value. That property is the whole
point: a student cannot "pass" by accident.

## Using Spike as the golden model instead

The harness depends only on a stream of commit dicts of the form
`{"pc", "rd", "rd_val", "mem_addr", "mem_val"}`. To use the reference Spike
simulator instead of the bundled Python model, write an adapter that runs
`spike --log-commits --isa=rv32i ...` and parses each commit-log line into one
of those dicts, then substitute it for `ISS` in `test_lockstep.py`. The
comparison code does not change. The bundled Python model is the zero-install
default and is itself readable by students; Spike is the industry-standard
upgrade once they want a model they didn't write.

## Notes / assumptions

- The core has separate instruction and data memories; the model mirrors that.
  Loads from never-written data addresses are undefined (the RTL would read X) —
  initialize data with stores first, as real programs do.
- One instruction retires per cycle (single-cycle core), so the lockstep is
  one ISS step per clock. When students add the multicycle `M` extension, the
  harness must wait for a `retire`/`done` strobe before stepping the model —
  a deliberate, instructive change to make at that point.
