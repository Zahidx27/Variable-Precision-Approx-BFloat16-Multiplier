`timescale 1ns / 1ps

module precision_ctl (
    input  [ 7:0] expa,
    input  [ 7:0] expb,
    output [10:0] mask
);

  wire signed [8:0] unbiased_expa, unbiased_expb;
  wire signed [9:0] unbiased_prod_exp;

  assign unbiased_expa = {1'b0, expa} - 9'd127;
  assign unbiased_expb = {1'b0, expb} - 9'd127;

  assign unbiased_prod_exp = unbiased_expa + unbiased_expb;

  // posit encoding the product exponent
  wire [9:0] exp_magnitude;
  wire       exp_sign;
  wire [3:0] rg;

  assign exp_sign = unbiased_prod_exp[9];
  assign exp_magnitude = exp_sign ? (~unbiased_prod_exp + 1) : unbiased_prod_exp;
  assign rg = exp_magnitude[7:4];

  // variable bit-width od product
  reg [3:0] bw_pd;
  always @(*) begin
    case (rg)
      4'h0: bw_pd = 11;  // rg=0: full precision 
      4'h1: bw_pd = 10;  // rg=1: high precision  
      4'h2: bw_pd = 9;  // rg=2: good precision
      4'h3: bw_pd = 8;  // rg=3: medium precision
      4'h4: bw_pd = 7;  // rg=4: reduced precision
      4'h5: bw_pd = 6;  // rg=5: low precision
      4'h6: bw_pd = 5;  // rg=6: minimal precision
      4'h7: bw_pd = 4;  // rg=7: minimum precision
      4'h8: bw_pd = 4;  // rg=8: minimum precision 
      4'h9: bw_pd = 5;  // rg=9: slightly more precision
      4'hA: bw_pd = 6;  // rg=10: low precision
      4'hB: bw_pd = 7;  // rg=11: reduced precision
      4'hC: bw_pd = 8;  // rg=12: medium precision
      4'hD: bw_pd = 9;  // rg=13: good precision
      4'hE: bw_pd = 10;  // rg=14: high precision
      4'hF: bw_pd = 11;  // rg=15: full precision
    endcase
  end

  reg [10:0] precision_mask;
  always @(*) begin
    case (bw_pd)
      4:  precision_mask = 11'b11110000000;
      5:  precision_mask = 11'b11111000000;
      6:  precision_mask = 11'b11111100000;
      7:  precision_mask = 11'b11111110000;
      8:  precision_mask = 11'b11111111000;
      9:  precision_mask = 11'b11111111100;
      10: precision_mask = 11'b11111111110;
      11: precision_mask = 11'b11111111111;

      default: precision_mask = 11'b11110000000;
    endcase
  end

  assign mask = precision_mask;
endmodule
