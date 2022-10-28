module core(
  input        clk,

  output [31:0]instr_addr,
  input  [31:0]instr_data,
  input  [31:0]last_pc,
    
  output [31:0]ram_raddr,
  input  [31:0]ram_rdata,
  output [31:0]ram_waddr,
  output [31:0]ram_wdata,
  output       ram_we
);

wire [31:0]instr = instr_data;
wire  [4:0] rd   = instr[11:7];
wire  [4:0]rs1   = instr[19:15];
wire  [4:0]rs2   = instr[24:20];

wire       ram_re;
wire [31:0]alu_result;
wire       is_jump;
reg  [31:0]pc        = 32'hFFFFFFFF;
wire  [4:0]rf_raddr0 = rs1;
wire [31:0]rf_rdata0;
wire  [4:0]rf_raddr1 = rs2;
wire [31:0]rf_rdata1;
wire  [4:0]rf_waddr  = rd;
wire [31:0]rf_wdata  = is_jump
                        ? pc + 1
                        : ram_re
                          ? ram_rdata
                          : alu_result;
wire rf_we;

reg_file rf(
  .clk(clk),
  .raddr0(rf_raddr0), .rdata0(rf_rdata0),
  .raddr1(rf_raddr1), .rdata1(rf_rdata1),
  .waddr (rf_waddr ), .wdata (rf_wdata ), .we(rf_we)
);

// RAM
assign ram_wdata = rf_rdata1;
assign ram_waddr = alu_result;
assign ram_raddr = alu_result;

wire has_imm;
wire [11:0]imm12;
wire [19:0]imm20;
wire [31:0]imm32 = is_jump
                    ? {{12{imm20[19]}}, imm20}
                    : {{20{imm12[11]}}, imm12};

wire [31:0]alu_a_src = rf_rdata0;
wire [31:0]alu_b_src = has_imm ? imm32 : rf_rdata1;
wire  [2:0]alu_op;
wire       alu_alt;

alu alu(
  .src_a (rf_rdata0 ),
  .src_b (alu_b_src ),
  .op    (alu_op    ),
  .alt   (alu_alt   ),
  .res   (alu_result)
);

wire is_branch;
wire is_check_eq;

control control(
  .instr       (instr      ),
  .has_imm     (has_imm    ),
  .imm12       (imm12      ),
  .imm20       (imm20      ),
  .alu_op      (alu_op     ),
  .alt         (alu_alt    ),
  .rf_we       (rf_we      ),
  .mem_we      (ram_we     ),
  .mem_re      (ram_re     ),
  .is_branch   (is_branch  ),
  .is_check_eq (is_check_eq),
  .is_jump     (is_jump     )
);


reg  [31:0]pc_next = 32'b0;

wire       is_taken      = is_branch
                            ? (is_check_eq ^ |alu_result)
                            : 1'b0;
wire [31:0]branch_target = pc + imm32;
wire [31:0]jump_target   = has_imm
                            ? alu_result
                            : branch_target;

always @(posedge clk) begin
  pc <= pc_next;
  $strobe("CPUv1: [%h] %h", pc, instr);
end

always @(negedge clk) begin
  if (is_jump)
    pc_next <= jump_target;
  else if (is_taken)
    pc_next <= branch_target;
  else
    pc_next <= pc + 1;
end

assign instr_addr = pc_next;

endmodule
