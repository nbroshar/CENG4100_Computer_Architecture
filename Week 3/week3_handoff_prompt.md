# Week 3 Handoff Prompt

Paste the block below into a chat to pick the course project up at Week 3.

**Fresh chat:** also attach `riscv_14week_curriculum.md`, the `rv32i_base/` folder
(at minimum `rtl/rv32i.v`, `rtl/rv32i_sim_top.v`, `verif/*`, and `solutions/popcount/`
as the reference pattern), the deck build script, and one of `ARCH_Week01.pptx` /
`ARCH_Week02.pptx` as the visual reference — the prompt names them so Claude knows what
it's reading.

**Same chat (continuing):** you can trim to just the *Week 3 goal*, *What to produce*,
and *Conventions* sections, since the rest of the context is already present.

---

```
I'm building a 14-week computer-architecture course: a semester project where students
build and extend a small RISC-V CPU, run it on a Basys 3 (Artix-7 / Vivado) FPGA, then
tape out an area-optimized version as an ASIC via Tiny Tapeout. Text: Patterson &
Hennessy, Computer Organization and Design, RISC-V edition. We're picking up at Week 3.

WHAT ALREADY EXISTS (attached — please read before starting):
- riscv_14week_curriculum.md — the full 14-week plan (brownfield: students start from a
  working core and extend it; each extension teaches a distinct architectural idea).
- rv32i_base/ — the student materials:
  • rtl/rv32i.v, rtl/rv32i_sim_top.v — a clean, COMPLETE single-cycle RV32I in Verilog,
    deliberately omitting sub-word memory (lb/lh/lbu/lhu/sb/sh), the M extension, and
    system instructions — those are the extension exercises. Touch points are marked
    `// <<< EXTEND` at the main decoder, ALU decoder, ALU, immediate gen, writeback mux.
  • verif/ — a cocotb lockstep harness (test_lockstep.py) that runs the RTL core against
    a golden Python ISS (rv32i_iss.py), comparing PC, register writeback, and stores every
    instruction; plus a tiny assembler (asm.py) and a coverage program (sanity.s).
  • tt/ — a Tiny Tapeout ASIC skeleton matching the current ttsky-verilog-template.
  • solutions/popcount/ — the reference-solution PATTERN: a unified diff vs the base, a
    test program, a captured lockstep log, and an instructor README.
- ARCH_Week01.pptx, ARCH_Week02.pptx — the slide decks, and the Node/pptxgenjs build
  script that generates them. They match my course template exactly: crimson 9E1B32,
  dark 1A1A1A, gray 595959, code-blue 1A56DB, pink card F8E8EC; fonts "Tw Cen MT Condensed
  Extra Bold" (titles) and "Tw Cen MT" (body); layouts = two-part titles with a red pipe,
  pink concept cards, numbered red-circle steps, editor/terminal mocks, a red "D" footer.

WHERE WE ARE: end of Week 2. Students have traced the core by hand, run lockstep against
the golden model, proven the gate catches a deliberately injected bug, and added their
first custom instruction (popcount), verified.

WEEK 3 GOAL (from the curriculum): the first architecturally meaty extension — SUB-WORD
MEMORY: lb, lh, lbu, lhu, sb, sh. It teaches byte lanes, address alignment, sign- vs
zero-extension on loads, and store byte-masking. Reading: P&H Ch 2 §2.8–2.10, Ch 5 §5.1.

WHAT TO PRODUCE FOR WEEK 3 (same bar as Weeks 1–2):
1. The RTL extension to rtl/rv32i.v adding the six sub-word load/store instructions —
   byte/halfword lane selection, sign vs zero extension, and store masking. Note the data
   memory in rv32i_sim_top.v is word-addressed, so handle byte enables / masking there too.
2. The matching golden-model edit (verif/rv32i_iss.py) and assembler support (verif/asm.py).
3. A lockstep-verified test program exercising all six across every byte offset and both
   signed/unsigned loads.
4. A reference solution in rv32i_base/solutions/subword-mem/ in the SAME format as
   solutions/popcount/ (unified diff vs base, test program, captured lockstep log,
   instructor README). VALIDATE it by applying the diff to a fresh copy of the base and
   running make sim — don't just claim it works; show the captured PASS.
5. A Week 3 deck (ARCH_Week03.pptx) matching the Week 1/2 template exactly, conceptual-
   then-step-by-step, with a worked example. Reuse/extend the existing build script.

CONVENTIONS TO KEEP:
- Keep the base core clean; extensions live in solutions/ so they don't spoil the exercise.
- Validate by running (assemble, simulate, capture real output) — the deck's terminal/code
  mocks should use real captured output, not invented text.
- Sub-word memory is still single-cycle, so the lockstep harness (one ISS step per cycle)
  works unchanged — unlike the future multicycle M extension.
- Match the deck template's existing motifs even where generic slide-design advice differs;
  the environment has cocotb 2.0 (use unit=, not units=), Icarus Verilog, and the pptx skill.

Start by proposing the sub-word-memory design (decode plan, datapath/memory changes, the
masking/extension approach) and a Week 3 deck outline, then build and validate.
```
