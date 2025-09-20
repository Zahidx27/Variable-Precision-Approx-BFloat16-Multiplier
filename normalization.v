`timescale 1ns / 1ps (* KEEP_HIERARCHY = "TRUE", DONT_TOUCH = "TRUE" *)

module normalization (
    input [16:0] mantissa_i,
    input [9:0] exponent_i,
    output reg [9:0] exponent,
    output reg [16:0] mantissa
);
  always @* begin
    if (mantissa_i[16] == 1'b1) begin
      exponent = exponent_i + 1'd1;
      // logical right shift
      mantissa = mantissa_i >> 1;
    end else begin
      exponent = exponent_i;
      mantissa = mantissa_i;
    end
  end
endmodule
