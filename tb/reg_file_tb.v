module reg_file_tb();
  logic clk, reset, we;
  logic [4:0] raddr0, raddr1, waddr;
  logic [31:0] wdata, rdata0, rdata1, rdata0_exp, rdata1_exp;
  logic [31:0] vectornum, errors;
  logic [110:0] testvectors[1000:0];

  reg_file reg_file(
    clk,
    raddr0, //5
    raddr1, //5
    waddr,  //5
    wdata,  //32
    we,
    rdata0, //32
    rdata1  //32
  );        //111
  
  always begin
    clk = 1; #10;
    clk = 0; #10;
  end

  initial begin
    $readmemb("reg_file_tb.dat", testvectors);
    vectornum = 0; errors = 0;
    reset = 0; we = 0;
    #15; reset = 1;
    #26; we = 1;
  end

  always @(posedge clk) begin
    #1; {raddr0, raddr1, waddr, wdata, rdata0_exp, rdata1_exp} = testvectors[vectornum];
  end

  always @(negedge clk) begin
    if (reset) begin
      if (rdata0 != rdata0_exp || rdata1 != rdata1_exp) begin
        $display("Error: inputs = r[%b] r[%b] w{%b} %d", raddr0, raddr1, waddr, wdata);
        $display(" outputs0 = %d {%d expected}", rdata0, rdata0_exp);
        $display(" outputs1 = %d {%d expected}", rdata1, rdata1_exp);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 111'bx) begin
        $display("%d tests completed with %d errors", vectornum, errors);
        $finish;
      end
    end
  end
endmodule
