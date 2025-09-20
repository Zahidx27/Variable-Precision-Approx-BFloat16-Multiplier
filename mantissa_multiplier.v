`timescale 1ns / 1ps (* KEEP_HIERARCHY = "TRUE", DONT_TOUCH = "TRUE" *)

module mantissa_multiplier (
    input  [10:0] mask,
    input  [ 7:0] manta,
    input  [ 7:0] mantb,
    output [16:0] mults,
    output [16:0] multc
);

  localparam WIDTH = 17;

  wire sign_a = manta[7];
  wire sign_b = mantb[7];

  // magnitudes
  wire [7:0] abs_a = sign_a ? (~manta + 8'b1) : manta;
  wire [7:0] abs_b = sign_b ? (~mantb + 8'b1) : mantb;

  wire [8:0] a_full = {1'b0, abs_a};
  wire [8:0] b_full = {1'b0, abs_b};

  // partial product array
  wire [10:0] pp[4:0];

  booth_encoder be0 (
      .multiplicand(a_full),
      .booth_sel({b_full[1:0], 1'b0}),
      .partial_product(pp[0])
  );
  booth_encoder be1 (
      .multiplicand(a_full),
      .booth_sel(b_full[3:1]),
      .partial_product(pp[1])
  );
  booth_encoder be2 (
      .multiplicand(a_full),
      .booth_sel(b_full[5:3]),
      .partial_product(pp[2])
  );
  booth_encoder be3 (
      .multiplicand(a_full),
      .booth_sel(b_full[7:5]),
      .partial_product(pp[3])
  );
  booth_encoder be4 (
      .multiplicand(a_full),
      .booth_sel({1'b0, b_full[8:7]}),
      .partial_product(pp[4])
  );

  wire signed [WIDTH-1:0] pp_shifted[4:0];
  assign pp_shifted[0] = $signed(pp[0]) <<< 0;
  assign pp_shifted[1] = $signed(pp[1]) <<< 2;
  assign pp_shifted[2] = $signed(pp[2]) <<< 4;
  assign pp_shifted[3] = $signed(pp[3]) <<< 6;
  assign pp_shifted[4] = $signed(pp[4]) <<< 8;

  // 17-bit mask from computed 11-bit mask:
  wire [WIDTH-1:0] truncate_mask = {1'b1, mask, 5'b00000};
  wire [WIDTH-1:0] pp_shifted_masked[4:0];

  assign pp_shifted_masked[0] = pp_shifted[0] & truncate_mask;
  assign pp_shifted_masked[1] = pp_shifted[1] & truncate_mask;
  assign pp_shifted_masked[2] = pp_shifted[2] & truncate_mask;
  assign pp_shifted_masked[3] = pp_shifted[3] & truncate_mask;
  assign pp_shifted_masked[4] = pp_shifted[4] & truncate_mask;

  wire [WIDTH-1:0] l1_s0, l1_c0, l1_s1, l1_c1;
  csa #(
      .WIDTH(WIDTH)
  ) csa_l1_0 (
      .a(pp_shifted_masked[0]),
      .b(pp_shifted_masked[1]),
      .c(pp_shifted_masked[2]),
      .sum(l1_s0),
      .carry(l1_c0)
  );
  csa #(
      .WIDTH(WIDTH)
  ) csa_l1_1 (
      .a(pp_shifted_masked[3]),
      .b(pp_shifted_masked[4]),
      .c({WIDTH{1'b0}}),
      .sum(l1_s1),
      .carry(l1_c1)
  );

  wire [WIDTH-1:0] l2_s0, l2_c0;
  csa #(
      .WIDTH(WIDTH)
  ) csa_l2_0 (
      .a(l1_s0),
      .b(l1_c0 << 1),
      .c(l1_s1),
      .sum(l2_s0),
      .carry(l2_c0)
  );

  csa #(
      .WIDTH(WIDTH)
  ) csa_final (
      .a(l2_s0),
      .b(l2_c0 << 1),
      .c(l1_c1 << 1),
      .sum(mults),
      .carry(multc)
  );

endmodule


module booth_encoder (
    input [8:0] multiplicand,  // unsigned magnitude
    input [2:0] booth_sel,
    output reg [10:0] partial_product
);

  wire [10:0] pos_1x = {2'b00, multiplicand};  // +1 * M
  wire [10:0] pos_2x = {1'b0, multiplicand, 1'b0};  // +2 * M (<<1)
  wire [10:0] neg_1x = (~pos_1x) + 11'b1;  // -1 * M
  wire [10:0] neg_2x = (~pos_2x) + 11'b1;  // -2 * M

  always @(*) begin
    case (booth_sel)
      3'b000: partial_product = 11'b0;
      3'b001, 3'b010: partial_product = pos_1x;
      3'b011: partial_product = pos_2x;
      3'b100: partial_product = neg_2x;
      3'b101, 3'b110: partial_product = neg_1x;
      3'b111: partial_product = 11'b0;
      default: partial_product = 11'b0;
    endcase
  end
endmodule


module csa #(
    parameter WIDTH = 17
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [WIDTH-1:0] c,
    output [WIDTH-1:0] sum,
    output [WIDTH-1:0] carry
);
  assign sum   = a ^ b ^ c;
  assign carry = (a & b) | (b & c) | (a & c);
endmodule
