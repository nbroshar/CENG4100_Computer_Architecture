// tt_rom.v -- instruction ROM for the Tiny Tapeout demo (sum 1..10 = 55).
// Regenerate: python3 ../../verif/asm.py prog.s -o prog.hex, then rebuild this case.
`default_nettype none
module tt_rom (input wire [5:0] addr, output reg [31:0] data);
    always @(*) begin
        case (addr)
            6'd0: data = 32'h00000093;
            6'd1: data = 32'h00100113;
            6'd2: data = 32'h00b00193;
            6'd3: data = 32'h002080b3;
            6'd4: data = 32'h00110113;
            6'd5: data = 32'hfe314ce3;
            6'd6: data = 32'h10000213;
            6'd7: data = 32'h00122023;
            6'd8: data = 32'h0000006f;
            default: data = 32'h00000013; // nop (addi x0,x0,0)
        endcase
    end
endmodule
