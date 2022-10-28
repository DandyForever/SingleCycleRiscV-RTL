module sign_ext(
  input [11:0]imm,

  output [31:0]ext_imm
);

wire sign = imm[11];
assign ext_imm = {{20{sign}}, imm};

endmodule
