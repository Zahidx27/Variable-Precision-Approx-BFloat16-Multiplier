module carry_prop_adder (
    input  [10:0] in1,
    input  [10:0] in2,
    output [10:0] sum
);
  wire [11:0] carry;
  assign carry[0] = 0;
  fullAdder fa0 (
      .a(in1[0]),
      .b(in2[0]),
      .c(carry[0]),
      .sum(sum[0]),
      .cout(carry[1])
  );
  fullAdder fa1 (
      .a(in1[1]),
      .b(in2[1]),
      .c(carry[1]),
      .sum(sum[1]),
      .cout(carry[2])
  );
  fullAdder fa2 (
      .a(in1[2]),
      .b(in2[2]),
      .c(carry[2]),
      .sum(sum[2]),
      .cout(carry[3])
  );
  fullAdder fa3 (
      .a(in1[3]),
      .b(in2[3]),
      .c(carry[3]),
      .sum(sum[3]),
      .cout(carry[4])
  );
  fullAdder fa4 (
      .a(in1[4]),
      .b(in2[4]),
      .c(carry[4]),
      .sum(sum[4]),
      .cout(carry[5])
  );
  fullAdder fa5 (
      .a(in1[5]),
      .b(in2[5]),
      .c(carry[5]),
      .sum(sum[5]),
      .cout(carry[6])
  );
  fullAdder fa6 (
      .a(in1[6]),
      .b(in2[6]),
      .c(carry[6]),
      .sum(sum[6]),
      .cout(carry[7])
  );
  fullAdder fa7 (
      .a(in1[7]),
      .b(in2[7]),
      .c(carry[7]),
      .sum(sum[7]),
      .cout(carry[8])
  );
  fullAdder fa8 (
      .a(in1[8]),
      .b(in2[8]),
      .c(carry[8]),
      .sum(sum[8]),
      .cout(carry[9])
  );
  fullAdder fa9 (
      .a(in1[9]),
      .b(in2[9]),
      .c(carry[9]),
      .sum(sum[9]),
      .cout(carry[10])
  );
  fullAdder fa10 (
      .a(in1[10]),
      .b(in2[10]),
      .c(carry[10]),
      .sum(sum[10]),
      .cout(carry[11])
  );
endmodule

module fullAdder (
    input  a,
    input  b,
    input  c,
    output sum,
    output cout
);
  assign sum  = a ^ b ^ c;
  assign cout = (a & b) | (a & c) | (b & c);
endmodule
