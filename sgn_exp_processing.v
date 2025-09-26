module sgn_exp_processing (
    input Sa,
    input Sb,
    input [7:0] expa,
    input [7:0] expb,
    output Spd,
    output [9:0] expt
);

  assign Spd = Sa ^ Sb;

  wire [9:0] exp_sum_biased;
  assign exp_sum_biased = $signed({2'b00, expa}) + $signed({2'b00, expb}) - 10'd127;
  assign expt = exp_sum_biased;

endmodule

