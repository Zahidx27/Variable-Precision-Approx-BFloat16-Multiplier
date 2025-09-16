`timescale 1ns / 1ps

module sgn_exp_processing (
    input Sa,
    input Sb,
    input [7:0] expa,
    input [7:0] expb,
    output Spd,
    output [9:0] expt
);

  assign Spd = Sa ^ Sb;

  wire [8:0] exp_sum_biased;
  assign exp_sum_biased = {1'b0, expa} + {1'b0, expb} - 9'd127;
  assign expt = {exp_sum_biased[8], exp_sum_biased};

endmodule

