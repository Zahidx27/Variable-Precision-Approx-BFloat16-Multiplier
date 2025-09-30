`timescale 1ns / 1ps (* KEEP_HIERARCHY = "TRUE", DONT_TOUCH = "TRUE" *)

module exception_handling (
    input [9:0] expt_pd,
    input [7:0] mantissa_pd,
    input       Spd,

    input [7:0] expa,
    input [6:0] manta,
    input [7:0] expb,
    input [6:0] mantb,
    input       sa,
    input       sb,

    output reg [15:0] Product  // bfloat16 result
);

  reg  [7:0] result_exp;
  reg  [6:0] result_manti;
  reg        result_sign;

  wire       a_is_zero = (expa == 8'h00) && (manta == 7'b0);
  wire       b_is_zero = (expb == 8'h00) && (mantb == 7'b0);
  wire       a_is_inf = (expa == 8'hFF) && (manta == 7'b0);
  wire       b_is_inf = (expb == 8'hFF) && (mantb == 7'b0);
  wire       a_is_nan = (expa == 8'hFF) && (manta != 7'b0);
  wire       b_is_nan = (expb == 8'hFF) && (mantb != 7'b0);

  always @(*) begin
    result_exp   = expt_pd[7:0];
    result_manti = mantissa_pd[6:0];
    result_sign  = Spd;

    // NaN
    if (a_is_nan || b_is_nan) begin
      result_exp   = 8'hFF;
      result_manti = 7'b0000001;  // quiet NaN
      result_sign  = 1'b0;

      // inf * 0 = NaN
    end else if ((a_is_inf && b_is_zero) || (a_is_zero && b_is_inf)) begin
      result_exp   = 8'hFF;
      result_manti = 7'b0000001;
      result_sign  = 1'b0;

      // inf * finite = inf
    end else if (a_is_inf || b_is_inf) begin
      result_exp   = 8'hFF;
      result_manti = 7'b0000000;
      result_sign  = sa ^ sb;

      // zero * finite = zero
    end else if (a_is_zero || b_is_zero) begin
      result_exp   = 8'h00;
      result_manti = 7'b0000000;
      result_sign  = sa ^ sb;

      // overflow
    end else if (!expt_pd[9] && (expt_pd[8] || expt_pd[7:0] >= 8'hFF)) begin
      result_exp   = 8'hFF;
      result_manti = 7'b0000000;

      // underflow
    end else if (expt_pd[9] || expt_pd == 10'd0) begin
      result_exp   = 8'h00;
      result_manti = 7'b0000000;
    end
  end

  always @(*) begin
    Product = {result_sign, result_exp, result_manti};
  end

endmodule

