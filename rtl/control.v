module control(
  input      [31:0]instr,

// i-type config
  output reg       has_imm,
  output reg [11:0]imm12,
  output reg [19:0]imm20,

// alu config
  output reg  [2:0]alu_op,
  output reg       alt,

// rf flags
  output reg       rf_we,

// ram flags
  output reg       mem_we,
  output reg       mem_re,
  
// branch flags
  output reg       is_branch,
  output reg       is_check_eq,
  output reg       is_jump
);

wire [6:0]opcode = instr[6:0];
wire [2:0]funct3 = instr[14:12];
wire [6:0]funct7 = instr[31:25];

always @(*) begin
  has_imm     = 1'b0;
  imm12       = 12'b0;
  imm20       = 20'b0;
  alu_op      = 3'b000;
  alt         = 1'b0;
  rf_we       = 1'b0;
  mem_we      = 1'b0;
  mem_re      = 1'b0;
  is_branch   = 1'b0;
  is_check_eq = 1'b0;
  is_jump     = 1'b0;

  casez (opcode)
    7'b0010011: begin /* ADDI SLLI SLTI SLTIU XORI SRLI SRAI ORI ANDI */
      rf_we       = 1'b1;
      alu_op      = funct3;
      imm12       = instr[31:20];
      has_imm     = 1'b1;
      alt         = (funct3 == 3'b101) && funct7[5];
    end
    7'b0110011: begin /* ADD SUB SLL SLT SLTU XOR SRL SRA OR AND */
      rf_we       = 1'b1;
      alu_op      = funct3;
      alt         = funct7[5];
    end
    7'b0100011: begin /* SW */
      imm12       = {instr[31:25], instr[11:7]};
      has_imm     = 1'b1;
      mem_we      = (funct3 == 3'b010);
    end
    7'b0000011: begin /* LW */
      imm12       = instr[31:20];
      has_imm     = 1'b1;
      mem_re      = 1'b1;
      rf_we       = 1'b1;
    end
    7'b1100011: begin /* BNE BEQ BLT BGE BLTU BGEU */
      alt         = ~funct3[2];
      alu_op      = {1'b0, funct3[2:1]};
      imm12       = {instr[31], instr[31], instr[7],
                    instr[30:25], instr[11:9]};
      is_branch   = 1'b1;
      is_check_eq = funct3[0] ^ ~funct3[2]; 
    end
    7'b1101111: begin /* JAL */
      imm20       = {instr[31], instr[31], instr[19:12],
                    instr[20], instr[30:22]};
      is_jump     = 1'b1;
      rf_we       = 1'b1;
    end
    7'b1100111: begin /* JALR */
      imm12       = instr[31:20];
      has_imm     = 1'b1;
      is_jump     = 1'b1;
      rf_we       = 1'b1;
    end
    default: ;
  endcase
end

endmodule
