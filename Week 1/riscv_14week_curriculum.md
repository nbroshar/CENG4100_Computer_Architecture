# RISC-V Microprocessor Design — 14-Week Curriculum (brownfield / extend-the-ISA edition)

**Text:** Patterson & Hennessy, *Computer Organization and Design, RISC-V Edition* (2nd ed.)
**Hardware:** Digilent Basys 3 (Xilinx Artix-7 XC7A35T)
**Students:** already fluent in Verilog — no syntax teaching; time goes to architecture, verification, and the ASIC backend.
**Shape:** start from a small, legible, *complete and runnable* single-cycle RV32I core; extend it with instructions chosen to teach architecture (not to fill a checklist); run on the FPGA; tape out an area-optimized version via Tiny Tapeout.

A reference base core is provided (`rv32i_base/`): complete RV32I, heavily commented, with explicit `// <<< EXTEND` points and a worked example (`popcount`).

---

## Why brownfield, and the rules that make it work

The goal — "a very small microprocessor students can add instructions to" — is inherently a brownfield activity, and a self-validating one: you cannot add a working instruction without understanding decode, immediate generation, datapath, and control as a connected whole, so it resists cargo-culting in a way that reading code alone does not.

Three rules keep it honest:

1. **The base must be legible** — single-cycle, one-screen opcode→datapath→control. Not a pipeline (hazard logic is unreadable), not a dense production core (picorv32), not bit-serial (SERV) — those are poor *extension* targets even though SERV is an excellent *ASIC* target.
2. **Trace before modify.** Before touching the RTL, each student instruments the provided core, traces a known instruction through it, and diffs architectural state against a golden ISA model (Spike). Hard gate; it converts "modify until tests pass" into a comprehension checkpoint.
3. **Extend for concept density, not coverage.** The base ships *complete and runnable*. We extend it only along axes that teach something new. Adding a sibling instruction that reuses an existing slot (e.g. `ori` once `andi` exists) is explicitly **not** an exercise — it is copy-paste in the same datapath path.

This unifies the two course goals: the small single-cycle core that is easiest to extend is also the best ASIC area target for a Tiny Tapeout tile. Pipelining is therefore an *optional performance track*, not a requirement.

## The extension ladder (each rung forces a new part of the machine into view)

- **Rung 0 — trace-before-modify gate.** Instrument and trace; diff against Spike. No RTL changes.
- **Rung 1 — warm-up (brief).** Add *one* instruction that reuses existing paths (e.g. a custom op routed through the ALU), just to prove the student can navigate decode → ALU-control → writeback. A day, not weeks.
- **Rung 2 — sub-word memory** (`lb lh lbu lhu sb sh`). A *designed gap* in the base. Teaches byte lanes, alignment, and sign- vs zero-extension on loads. Touches the data-memory path and a new immediate/store-mask concern.
- **Rung 3 — a custom functional unit written from scratch** (popcount / clz / min-max). New ALU operation end-to-end; the read-modify-*plus*-write-new beat.
- **Rung 4 — the `M` extension, multicycle** (`mul`, then `div`). A *designed gap*, and the richest lesson: the single-cycle assumption breaks, forcing a multicycle datapath with a stall/done handshake and a small control FSM. This also motivates the optional pipeline track that follows.

The base omits Rungs 2 and 4 *by design* — because those omissions are exactly the architectural lessons — and is otherwise complete, so students never burn weeks rebuilding plumbing.

---

## Toolchain (install and smoke-test in Week 1)

**FPGA / sim:** Vivado (Standard edition supports the XC7A35T); Verilator and Icarus for simulation; **cocotb** for testbenches (Tiny Tapeout's native style — adopt it now); GTKWave/Surfer; a RISC-V GCC/LLVM toolchain to assemble programs; **Spike** as the golden ISA model.

**ASIC (all free / open source):** **Yosys** (synth) → **OpenROAD** (floorplan/place/CTS/route) → **LibreLane** or **OpenLane 2** (flow orchestration) → **Magic / KLayout** (layout, DRC) + **Netgen** (LVS); **ngspice** for any pad-ring/analog checks; PDK via the `ciel`/`volare` manager. **PDK:** SKY130 (ChipFoundry shuttles) or IHP SG13G2 (EU). **Tapeout route:** Tiny Tapeout, using the cocotb project template and the GitHub-Actions GDS workflow.

> Week-1 smoke test: take a trivial counter all the way to GDSII through LibreLane *and* run the provided base core on the board. Prove both ends of the toolchain before any real RTL work, while there is still schedule slack.

---

## Weekly plan

### Week 1 — Setup + a working CPU you didn't write
**P&H:** Ch 1 (performance equation, CPI, the great ideas — frames the term).
**Lab:** Stand up the full toolchain. Get the provided complete single-cycle RV32I running on the Basys 3 and in cocotb. Run the counter→GDS smoke test.
**Deliverable:** Base core on hardware + a counter GDS. Toolchain sign-off.

### Week 2 — ISA + the comprehension gate + warm-up extension
**P&H:** Ch 2, §2.1–2.7 (formats, registers, encoding regularity).
**Lab (Rungs 0–1):** Instrument the base core; trace several instructions cycle-by-cycle; diff against Spike. Then the warm-up: add one instruction that reuses existing paths, to prove navigation of decode → ALU-control → writeback.
**Deliverable:** Passing trace-diff report + one verified warm-up instruction.

### Week 3 — Memory, addressing, and byte lanes
**P&H:** Ch 2, §2.8–2.10 (loads/stores, addressing) + Ch 5, §5.1 (locality preview).
**Lab (Rung 2):** Add sub-word memory (`lb/lh/lbu/lhu/sb/sh`). This is the first architecturally meaty extension — byte lanes, alignment, sign/zero extension, store masking.
**Deliverable:** Sub-word loads/stores verified against Spike across alignments and signedness.

### Week 4 — Arithmetic + a custom functional unit
**P&H:** Ch 3, §3.1–3.3 (two's complement, overflow, adders).
**Lab (Rung 3):** Design a new functional unit from scratch (popcount, clz, or min/max) and wire it in as a custom op. The from-scratch-Verilog beat.
**Deliverable:** Working custom instruction + a self-checking differential test.

### Week 5 — Multicycle: the `M` extension
**P&H:** Ch 3, §3.4–3.5 (multiply, divide, latency/area tradeoffs).
**Lab (Rung 4):** Add `mul` (then `div` as a stretch) as a *multicycle* operation: a small control FSM, a stall/done handshake, and PC hold. This is where students feel the single-cycle limit firsthand.
**Deliverable:** Multicycle multiply integrated and verified; a written note on the control changes it forced.

### Week 6 — Verification as a discipline
**P&H:** (light) — methodology week.
**Lecture/lab:** Build the reusable cocotb regression that gates every later change: directed tests per instruction class, **differential/random testing against Spike**, coverage of every rung. This is where the reclaimed (no-syntax-teaching) time lands.
**Deliverable:** A self-checking regression suite that fails loudly; CI green.

### Week 7 — **Milestone: extended core on FPGA**
**P&H:** Ch 4, §4.1–4.4 (datapath/control reference — read against the core they now know intimately).
**Lab:** Freeze a verified, complete, custom-extended core on the Basys 3. *Optional performance track* opens for anyone who wants it: convert single-cycle → multicycle generally, or stage toward a pipeline (Ch 4, §4.5–4.8). Framed as enhancement; not required.
**Deliverable (Milestone):** Verified extended RV32I, live on hardware, full regression passing.

### Week 8 — Memory hierarchy *or* a second extension (student choice)
**P&H:** Ch 5, §5.2–5.4 (caches, write policies).
**Lab:** Either add a small direct-mapped cache in front of block RAM and measure hit rate/CPI impact (FPGA-only enhancement), or design a second custom instruction / mini-accelerator op. Keep cache *out* of the ASIC config for area reasons.
**Deliverable:** Measured cache study or a second verified extension.

### Week 9 — Consolidation + ASIC on-ramp
**P&H:** Ch 6, §6.1–6.3 (parallelism context — light).
**Lecture/lab:** Polish and document the extended ISA. Read the FPGA-vs-ASIC delta: standard cells vs. LUTs, no free block RAM, real timing closure, the Tiny Tapeout tile budget (~161×112 µm/tile on SKY130) and IO constraints. Define the ASIC config (which extensions stay, which get cut for area — `M` multiply is a prime cut candidate).
**Deliverable:** Frozen ASIC-config RTL + an area target in tiles.

### Week 10 — Synthesis and area shaping
**Lab:** Port the ASIC-config core into the Tiny Tapeout template. Run Yosys; read the cell/area report; iterate down to the chosen tile budget. The small single-cycle core fits comfortably — this is where being "very small" pays off.
**Deliverable:** Synthesized core within the tile budget.

### Week 11 — Hardening: floorplan, place, route
**Lab:** First full LibreLane hardening runs. Read OpenROAD floorplan/congestion/timing reports; iterate on utilization and pin placement.
**Deliverable:** A routed design with readable signoff reports.

### Week 12 — Signoff: DRC, LVS, timing, gate-level sim
**Lab:** Clean DRC (Magic/KLayout) and LVS (Netgen). Close timing at the target clock. Run **gate-level simulation of the hardened netlist against the same Week-6 regression** — the silicon must pass the same tests the FPGA did.
**Deliverable:** DRC-clean, LVS-clean, timing-closed netlist passing gate-level regression.

### Week 13 — Tapeout package + submission
**Lab:** Final GDSII. Assemble the Tiny Tapeout submission: cocotb harness, datasheet/docs, pin mapping to the demo board, green GDS workflow. Submit to the current open shuttle — **confirm the live SKY130/IHP/GF180 shuttle and its deadline at submission time; they rotate, and ownership terms differ (IHP runs are chip-on-loan; SKY130/GF180 are not).**
**Deliverable:** Submitted, signoff-clean GDSII on a real shuttle.

### Week 14 — **Capstone: demo + report**
**Deliverables:**
1. The extended RV32I running on the Basys 3 — live demo, including the student's custom instruction(s).
2. The submitted, signoff-clean ASIC GDS of the area-optimized core.
3. A design report: base core understood (trace evidence), each extension rung, verification methodology, FPGA results, ASIC area/timing/DRC/LVS results, and the FPGA-vs-ASIC tradeoffs.

---

## Milestones & assessment (suggested)
- Trace-before-modify gate (Week 2): pass/fail prerequisite.
- Extension rungs (sub-word mem, custom unit, multicycle `M`), verified: 35%
- Verification suite quality (Week 6): 15%
- Milestone — extended core on FPGA (Week 7): 15%
- Capstone — FPGA demo + ASIC tapeout + report (Weeks 13–14): 35%

Weight *verified* work above work that merely appears to run. Make the cocotb regression a hard gate at each milestone, and require differential testing against Spike for every extension.

---

## Risk notes
- **Shuttle deadlines drive the real schedule.** Pick the target shuttle in Week 1 and back-plan; a 14-week term may not align with a close date, in which case students submit just after the course.
- **The base is chosen for legibility, not realism.** A clean, complete, heavily-commented single-cycle core with explicit extension points beats any production core for this purpose.
- **Area is the ASIC wall, not function.** Keep the ASIC config minimal; cut caches and the `M` extension. The single-cycle smallness is the feature.
- **Verify the flow before you need it** (Week-1 counter→GDS), and run gate-level regression against the same tests the FPGA passed.
