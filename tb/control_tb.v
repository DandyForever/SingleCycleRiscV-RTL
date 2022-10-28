module control_tb();
  logic clk, reset;
  logic [31:0] instr;
  logic [11:0] imm12, imm12_exp;
  logic rf_we, rf_we_exp;
  logic [2:0] alu_op, alu_op_exp;
  logic [31:0] vectornum, errors;
  logic [43:0] testvectors[1000:0];

  control control(instr, imm12, rf_we, alu_op);
  
  always begin
    clk = 1; #10;
    clk = 0; #10;
  end

  initial begin
    $readmemb("control_tb.dat", testvectors);
    vectornum = 0; errors = 0;
    reset = 0;
    #15; reset = 1;
  end

  always @(posedge clk) begin
    #1; {instr, imm12_exp} = testvectors[vectornum];
  end

  always @(negedge clk) begin
    if (reset) begin
      if (imm12 != imm12_exp) begin
        $display("Error: inputs = %b", instr);
        $display(" outputs = %d {%d expected}", imm12, imm12_exp);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 44'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
  end
endmodule
