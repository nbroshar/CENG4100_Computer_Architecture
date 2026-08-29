# Tiny Tapeout project skeleton (ASIC config)

The design-specific parts of a Tiny Tapeout submission for the RV32I core. These
drop into a fresh clone of the **current** template so you inherit the CI
(synthesis, hardening, DRC/LVS, GDS, docs) without hand-maintaining it.

```
tt/
├── info.yaml          # project metadata, pinout, tile budget, source list
├── src/
│   ├── project.v      # tt_um_rv32i: adapts the core to the tile interface
│   ├── rv32i.v        # the CPU (copied from ../rtl)
│   └── tt_rom.v       # on-chip instruction ROM (generated from asm.py)
├── test/
│   ├── tb.v           # cocotb test harness
│   ├── test.py        # drives the chip pins, checks the result
│   └── Makefile       # local RTL sim (the template's Makefile also does gates)
└── docs/
    └── info.md        # datasheet rendered on the TT website
```

## Workflow

1. On GitHub, open **TinyTapeout/ttsky-verilog-template** (the current SKY130 /
   ChipFoundry template; it builds with LibreLane) and click **Use this
   template** to create your own repo. Confirm this is still the recommended
   template for the shuttle you are targeting — the template name tracks the
   active process (SKY130, IHP, or GF180).
2. Copy `info.yaml`, `src/*`, `test/*`, and `docs/info.md` from here into your
   new repo, overwriting the placeholders.
3. Set `author` (and ideally a unique `top_module` like `tt_um_rv32i_yourname`)
   in `info.yaml`. Keep `source_files` and `test/Makefile`'s `PROJECT_SOURCES`
   in sync.
4. Enable GitHub Actions / Pages. The `gds` workflow hardens the design and the
   `test` workflow runs the cocotb test.
5. Read the area report. The 32x32 register file dominates; if `2x2` is too
   small, bump `tiles`, or reduce to RV32E (16 registers) as a deliberate
   ABI/area tradeoff.
6. Submit at app.tinytapeout.com before the shuttle deadline.

## Run the test locally

```
cd test
make sim       # Icarus + cocotb; expects result 55
```

## What this validates vs. what the shuttle does

Local `make sim` proves RTL behavior. The GitHub Action additionally runs
synthesis, placement, routing, DRC, LVS, and produces the GDSII that actually
goes to the fab — and re-runs the test on the gate-level netlist. The silicon
must pass the same test the RTL did, which is why the cocotb test is written
against the pin interface, not internal signals.

## Regenerating the ROM

The demo program is compiled by the bundled assembler:

```
python3 ../verif/asm.py your_prog.s -o your_prog.hex
```

Then rebuild `src/tt_rom.v` as a `case` over the hex words (see the header of
that file). Keeping the program in ROM as synthesized logic avoids any
`$readmemh` file-path issues during hardening.
