module CPU
(
    clk_i, 
    rst_i,
);

// Ports
input               clk_i;
input               rst_i;

wire [6:0]  opcode = instr[6:0];
wire [1:0]  alu_op;
wire        alu_src;
wire        reg_write;

wire [31:0] pc_cur, pc_next;

wire [31:0] rs1_data, rs2_data;
wire [31:0] imm_ext; 
wire [31:0] alu_data2; 

wire [2:0]  alu_ctrl;
wire [31:0] alu_result;

wire [31:0] instr; 

wire [4:0] rs1 = instr[19:15];
wire [4:0] rs2 = instr[24:20];
wire [4:0] rd  = instr[11:7];


// You can design the below modules, or define your own modules to complete the CPU design
Control u_Control(
    .opcode_i (opcode),
    .ALUOp_o  (alu_op),
    .ALUSrc_o (alu_src),
    .RegWrite_o (reg_write)
);

Adder u_Add_PC(
    .data1_i (pc_cur),
    .data2_i (32'd4),
    .data_o (pc_next)
);

MUX32 u_MUX_ALUSrc(
    .data1_i (rs2_data),
    .data2_i (imm_ext),
    .select_i (alu_src),
    .data_o (alu_data2)
);

Sign_Extend u_Sign_Extend(
    .data_i (instr[31:20]),
    .data_o (imm_ext)
);
  
ALU u_ALU(
    .data1_i (rs1_data),
    .data2_i (alu_data2),
    .ALUCtrl_i (alu_ctrl),
    .data_o (alu_result)
);

ALU_Control u_ALU_Control(
    .func_i ({instr[31:25], instr[14:12]}),
    .ALUOp_i (alu_op),
    .ALUCtrl_o (alu_ctrl)
);

// provided by TA, you just need to connect the ports
PC u_PC(
    .clk_i (clk_i),
    .rst_i (rst_i),
    .pc_i (pc_next),
    .pc_o (pc_cur)
);

Instruction_Memory u_Instruction_Memory(
    .addr_i (pc_cur), 
    .instr_o (instr)
);

Registers u_Registers(
    .rst_i (rst_i),
    .clk_i (clk_i),
    .RS1addr_i (rs1),
    .RS2addr_i (rs2),
    .RDaddr_i (rd), 
    .RDdata_i (alu_result),
    .RegWrite_i (reg_write), 
    .RS1data_o (rs1_data), 
    .RS2data_o (rs2_data)
);

endmodule

