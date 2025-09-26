module normalization (
    input [10:0] mantissa_i,
    input [9:0] exponent_i,
    output reg [9:0] exponent,
    output [7:0] mantissa_pd
);
  reg overflow;
  reg [10:0] mantissa;
    always @(*) begin
    if (mantissa_i[10] == 1'b1) begin
      exponent = exponent_i + 1'd1;
      overflow = 1;
      // logical right shift
      mantissa = mantissa_i >> 1;
    end else begin
      exponent = exponent_i;
      mantissa = mantissa_i;
      overflow = 0;
    end
  end

  assign mantissa_pd = mantissa[9:2];
endmodule
