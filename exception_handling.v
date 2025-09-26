`timescale 1ns / 1ps (* KEEP_HIERARCHY = "TRUE", DONT_TOUCH = "TRUE" *)

module exception_handling (
    input      [ 9:0] expt_pd,
    input      [ 7:0] mantissa_pd,
    input             Spd,
    output reg [15:0] Product       // bfloat16 result
);

  reg [7:0] result_exp;
  reg [6:0] result_manti;


    always @(*) begin
    result_exp   = expt_pd[7:0];
    result_manti = mantissa_pd[6:0];

    // Overflow Check
    if (!expt_pd[9] && (expt_pd[8] || expt_pd[7:0] >= 8'hFF)) begin
      result_exp   = 8'hFF;  // infinity exponent
      result_manti = 7'b0000000;  // zero mantissa for infinity
    end  
    // Underflow Check 
    else if (expt_pd[9] || expt_pd == 10'd0) begin
      result_exp   = 8'h00;  // zero exponent  
      result_manti = 7'b0000000;  // zero mantissa
    end

  end

    always @(*) begin
    Product = {Spd, result_exp, result_manti};
  end

endmodule
