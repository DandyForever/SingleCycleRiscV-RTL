module cpu_top(
  input clk
);

wire [31:0]instr_addr;
wire [31:0]instr_data;

rom rom(
  .clk (clk       ),
  .addr(instr_addr),
  .q   (instr_data)
);

wire [31:0]ram_raddr;
wire [31:0]ram_waddr;
wire [31:0]ram_wdata;
wire [31:0]ram_rdata;
wire       ram_we;

ram ram(
  .clk   (clk      ),
  .r_addr(ram_raddr),
  .w_addr(ram_waddr),
  .w_data(ram_wdata),
  .we    (ram_we   ),
  .r_data(ram_rdata)
);

core core(
  .clk       (clk         ),
  .instr_data(instr_data  ),
  .last_pc   (32'hFFFFFFFE),
  .instr_addr(instr_addr  ),
  .ram_raddr (ram_raddr   ),
  .ram_waddr (ram_waddr   ),
  .ram_wdata (ram_wdata   ),
  .ram_we    (ram_we      ),
  .ram_rdata (ram_rdata   )
);

endmodule
