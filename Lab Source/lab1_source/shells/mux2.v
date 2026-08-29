`timescale 1ns/1ps
// ============================================================================
//  mux2  --  the selector: pass in0 when sel=0, in1 when sel=1.
//  Route the AND result to in0 and the OR result to in1, so sel chooses which
//  parallel operation reaches the LEDs.
//  STRUCTURE PHASE: leave the body empty and wire this block in IP Integrator.
//  BEHAVIOR PHASE : add the one line marked TODO, then re-synthesize.
// ============================================================================
module mux2(
    input  [3:0] in0,   // shown when sel = 0   (wire the AND result here)
    input  [3:0] in1,   // shown when sel = 1   (wire the OR  result here)
    input        sel,
    output [3:0] y
);
    // TODO (behavior phase):  assign y = sel ? in1 : in0;
endmodule
