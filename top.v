`timescale 1ns / 1ps (* KEEP_HIERARCHY = "TRUE", DONT_TOUCH = "TRUE" *)

module top (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] Product
);

  wire Sa, Sb, Spd;
  wire [7:0] expa, expb;
  wire [9:0] expt, expt_pd;
    wire [7:0] manta, mantb;  //explicit mantissa
  wire [10:0] mask;
  wire [16:0] mults, multc;
  wire [16:0] mantissa_temp, mantissa_pd;

  inp_processing ip (
      .A(A),
      .B(B),
      .Sa(Sa),
      .Sb(Sb),
      .expa(expa),
      .manta(manta),  // mantissa of input A with leading 1
      .expb(expb),
      .mantb(mantb)  // mantissa of input B with leading 1
  );

  precision_ctl pc (
      .expa(expa),
      .expb(expb),
      .mask(mask)   // mask bits to control truncation
  );

  sgn_exp_processing sgnexp (
      .Sa  (Sa),
      .Sb  (Sb),
      .expa(expa),
      .expb(expb),
      .Spd (Spd),
      .expt(expt)
  );

  mantissa_multiplier mm (
      .mask (mask),
      .manta(manta),
      .mantb(mantb),
      .mults(mults),
      .multc(multc)
  );

  carry_prop_adder cpa (
      .in1(mults),
      .in2(multc),
      .sum(mantissa_temp)
  );

  normalization norm (
      .mantissa_i(mantissa_temp),
      .exponent_i(expt),
      .exponent  (expt_pd),
      .mantissa  (mantissa_pd)
  );

  exception_handling eh (
      .expt_pd(expt_pd),
      .mantissa_pd(mantissa_pd),
      .Spd(Spd),
      .Product(Product)
  );

endmodule
