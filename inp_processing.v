`timescale 1ns / 1ps

module inp_processing (
    input [15:0] A,
    input [15:0] B,
    output Sa,
    output Sb,
    output [7:0] expa,
    output [7:0] expb,
    output [7:0] manta,
    output [7:0] mantb
);
  // BFloat16 format: [15] sign, [14:7] exponent, [6:0] mantissa

  assign Sa = A[15];
  assign Sb = B[15];

  assign expa = A[14:7];
  assign expb = B[14:7];

  assign manta = {1'b1, A[6:0]};
  assign mantb = {1'b1, B[6:0]};

endmodule
