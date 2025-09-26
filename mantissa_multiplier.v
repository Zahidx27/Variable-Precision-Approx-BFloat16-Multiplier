module mantissa_multiplier (
    input  [10:0] mask,
    input  [ 7:0] manta,
    input  [ 7:0] mantb,
    output [10:0] mults,
    output [10:0] multc
);

  wire [9:0] pp[4:0];

  booth_encoder be0 (
      .multiplicand(manta),
      .booth_sel({mantb[1:0], 1'b0}),
      .partial_product(pp[0])
  );
  booth_encoder be1 (
      .multiplicand(manta),
      .booth_sel(mantb[3:1]),
      .partial_product(pp[1])
  );
  booth_encoder be2 (
      .multiplicand(manta),
      .booth_sel(mantb[5:3]),
      .partial_product(pp[2])
  );
  booth_encoder be3 (
      .multiplicand(manta),
      .booth_sel(mantb[7:5]),
      .partial_product(pp[3])
  );

  booth_encoder be4 (
      .multiplicand(manta),
      .booth_sel({2'b00, mantb[7]}),
      .partial_product(pp[4])
  );

  wire [10:0] pp_shifted[4:0];


  assign pp_shifted[0] = {{6{pp[0][9]}}, pp[0][9:5]};
  assign pp_shifted[1] = {{4{pp[1][9]}}, pp[1][9:3]};
  assign pp_shifted[2] = {{2{pp[2][9]}}, pp[2][9:1]};
  assign pp_shifted[3] = {pp[3], 1'b0};
  assign pp_shifted[4] = {pp[4][7:0], 3'b000};


  wire [10:0] pp_shifted_masked[4:0];
  assign pp_shifted_masked[0] = pp_shifted[0] & mask;
  assign pp_shifted_masked[1] = pp_shifted[1] & mask;
  assign pp_shifted_masked[2] = pp_shifted[2] & mask;
  assign pp_shifted_masked[3] = pp_shifted[3] & mask;
  assign pp_shifted_masked[4] = pp_shifted[4] & mask;

  wire [10:0] l1_s0, l1_c0, l1_s1, l1_c1;
  csa #(
      .WIDTH(11)
  ) csa_l1_0 (
      .a(pp_shifted_masked[0]),
      .b(pp_shifted_masked[1]),
      .c(pp_shifted_masked[2]),
      .sum(l1_s0),
      .carry(l1_c0)
  );
  csa #(
      .WIDTH(11)
  ) csa_l1_1 (
      .a(pp_shifted_masked[3]),
      .b(pp_shifted_masked[4]),
      .c({11{1'b0}}),
      .sum(l1_s1),
      .carry(l1_c1)
  );

  wire [10:0] l2_s0, l2_c0;
  csa #(
      .WIDTH(11)
  ) csa_l2_0 (
      .a(l1_s0),
      .b(l1_c0 << 1),
      .c(l1_s1),
      .sum(l2_s0),
      .carry(l2_c0)
  );

  csa #(
      .WIDTH(11)
  ) csa_final (
      .a(l2_s0),
      .b(l2_c0 << 1),
      .c(l1_c1 << 1),
      .sum(mults),
      .carry(multc)
  );

endmodule


module booth_encoder (
    input [7:0] multiplicand,
    input [2:0] booth_sel,
    output reg [9:0] partial_product
);

  wire [9:0] pos_1x = {2'b00, multiplicand};  // +1 * M
  wire [9:0] pos_2x = {1'b0, multiplicand, 1'b0};  // +2 * M
  wire [9:0] neg_1x = (~pos_1x) + 10'b1;  // -1 * M
  wire [9:0] neg_2x = (~pos_2x) + 10'b1;  // -2 * M

  always @(*) begin
    case (booth_sel)
      3'b000:  partial_product = 10'b0;
      3'b001:  partial_product = pos_1x;
      3'b010:  partial_product = pos_1x;
      3'b011:  partial_product = pos_2x;
      3'b100:  partial_product = neg_2x;
      3'b101:  partial_product = neg_1x;
      3'b110:  partial_product = neg_1x;
      3'b111:  partial_product = 10'b0;
      default: partial_product = 10'b0;
    endcase
  end
endmodule


module csa #(
    parameter WIDTH = 11
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
