module alu_tb();
  logic clk, reset;
  logic [31:0] src_a, src_b, res_exp, res;
  logic [2:0] op;
  logic [31:0] vectornum, errors;
  logic [98:0] testvectors[1000:0];

  alu alu(src_a, src_b, op, res);
  
  always begin
    clk = 1; #10;
    clk = 0; #10;
  end

  initial begin
    $readmemb("alu_tb.dat", testvectors);
    vectornum = 0; errors = 0;
    reset = 0;
    #15; reset = 1;
  end

  always @(posedge clk) begin
    #1; {src_a, src_b, op, res_exp} = testvectors[vectornum];
  end

  always @(negedge clk) begin
    if (reset) begin
      if (res != res_exp) begin
        $display("Error: inputs = %b + %b", src_a, src_b);
        $display(" outputs = %b {%b expected}", res, res_exp);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 99'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
  end
endmodule
