module CPU
(
    clk_i, 
    rst_n
);

// Ports
input         clk_i;
input         rst_n;

// Do not change the name of these 2 signals
wire ID_Stall;
wire ID_FlushIF;
wire NoOp;

wire PcWrite;
wire [31:0] pc_i, pc_o, pc_add4;



wire [31:0] branch_addr;
wire branch;
wire branch_taken;

wire [31:0] IF_instr;


wire [31:0] ID_instr;
wire ID_RegWrite;
wire ID_MemtoReg;
wire ID_MemRead;
wire ID_MemWrite;
wire [1:0] ID_ALUOp;
wire ID_ALUSrc;
wire [31:0] ID_Rs1data;
wire [31:0] ID_Rs2data;
wire [31:0] imm_o;
wire [31:0] ID_PC;
wire [6:0] opcode = ID_instr[6:0];

wire [4:0] WB_Rd_addr;
wire WB_RegWrite;

wire [4:0] MEM_addr;
wire MEM_MemRead;
wire MEM_MemWrite;
wire [31:0] MEM_data_i;
wire [31:0] MEM_data_o;
wire [31:0] MEM_Alu_result;

wire EX_RegWrite;
wire EX_MemtoReg;
wire EX_MemRead;
wire EX_MemWrite;
wire [1:0] EX_ALUOp;
wire EX_ALUSrc;
wire [31:0] EX_RS1_data;
wire [31:0] EX_RS2_data;
wire [31:0] EX_imm;
wire [4:0] EX_Rd_addr;
wire [31:0] Alu_input_1;
wire [31:0] Alu_input_2_data;
wire [31:0] Alu_input_2_imm;
wire [31:0] Alu_input_2;
wire [2:0]  ALU_Ctrl;
wire [31:0] EX_Alu_result;
wire [31:0] EX_instr;
wire [9:0]  EX_func;
wire [4:0] EX_RS1_addr;
wire [4:0] EX_RS2_addr;


wire [31:0] WB_Wr_data;
wire WB_MemtoReg;
wire [31:0] WB_MEMData;
wire [31:0] WB_Alu_result;

wire [1:0] forward_a;
wire [1:0] forward_b;


assign ID_FlushIF = branch_taken;


PC u_PC(
    .rst_n          (rst_n),
    .clk_i          (clk_i),
    .PCWrite_i      (PcWrite),
    .pc_i           (pc_i),
    .pc_o           (pc_o)
);

Adder PC_Adder(
    .data1_i        (pc_o),
    .data2_i        (32'd4),
    .data_o         (pc_add4)
);

MUX32 PC_MUX(
    .data1_i        (pc_add4),
    .data2_i        (branch_addr), 
    .select_i       (branch_taken),  // Branch control signal to be connected later
    .data_o         (pc_i)
);

Instruction_Memory u_Instruction_Memory(
    .addr_i         (pc_o), 
    .instr_o        (IF_instr)
);


IF_ID u_IF_ID(
    .clk_i          (clk_i),
    .rst_n          (rst_n),
    .stall_i        (ID_Stall),
    .flush_i        (ID_FlushIF),
    .pc_i           (pc_o),
    .instr_i        (IF_instr),

    .pc_o           (ID_PC),             
    .instr_o        (ID_instr)
);

Control u_Control(
    .opcode_i       (opcode),
    .NoOp_i         (NoOp),

    .RegWrite_o     (ID_RegWrite),
    .MemtoReg_o     (ID_MemtoReg),
    .MemRead_o      (ID_MemRead),
    .MemWrite_o     (ID_MemWrite),
    .ALUOp_o        (ID_ALUOp),
    .ALUSrc_o       (ID_ALUSrc),
    .Branch_o       (branch)
);

Sign_Extend u_Sign_Extend(
    .instr_i        (ID_instr),
    .imm_o          (imm_o)
);

Branch_Unit u_Branch_Unit(
    .pc_i           (ID_PC),
    .branch_i       (branch),
    .rs1_data_i     (ID_Rs1data),
    .rs2_data_i     (ID_Rs2data),
    .imm_i          (imm_o),
    .func3_i        (ID_instr[14:12]),

    .branch_addr_o  (branch_addr),
    .branch_taken_o (branch_taken)
);

Registers u_Registers(
    .rst_n          (rst_n),
    .clk_i          (clk_i),
    .RS1addr_i      (ID_instr[19:15]),
    .RS2addr_i      (ID_instr[24:20]),
    .RDaddr_i       (WB_Rd_addr),
    .RDdata_i       (WB_Wr_data),
    .RegWrite_i     (WB_RegWrite), 
    .RS1data_o      (ID_Rs1data), 
    .RS2data_o      (ID_Rs2data) 
);

ID_EX u_ID_EX(
    .clk_i          (clk_i),
    .rst_n          (rst_n),

    .RegWrite_i     (ID_RegWrite),
    .MemtoReg_i     (ID_MemtoReg),
    .MemRead_i      (ID_MemRead),
    .MemWrite_i     (ID_MemWrite),
    .ALUOp_i        (ID_ALUOp),
    .ALUSrc_i       (ID_ALUSrc),
    .rs1_data_i      (ID_Rs1data),
    .rs2_data_i      (ID_Rs2data),
    .imm_i          (imm_o),
    .func_i         ({ID_instr[31:25], ID_instr[14:12]}), // [9:3] = funct7, [2:0] = funct3
    .rs1_addr_i     (ID_instr[19:15]),
    .rs2_addr_i     (ID_instr[24:20]),
    .rd_addr_i      (ID_instr[11:7]),

    .RegWrite_o     (EX_RegWrite),
    .MemtoReg_o     (EX_MemtoReg),
    .MemRead_o      (EX_MemRead),
    .MemWrite_o     (EX_MemWrite),
    .ALUOp_o        (EX_ALUOp),
    .ALUSrc_o       (EX_ALUSrc),
    .rs1_data_o     (EX_RS1_data),
    .rs2_data_o     (EX_RS2_data),
    .func_o         (EX_func),
    .imm_o          (EX_imm),
    .rs1_addr_o     (EX_RS1_addr),
    .rs2_addr_o     (EX_RS2_addr),
    .rd_addr_o      (EX_Rd_addr)
);

MUX3 Alu_input_1_MUX(
    .data1_i        (EX_RS1_data),
    .data2_i        (WB_Wr_data), 
    .data3_i        (MEM_Alu_result),  
    .select_i       (forward_a),  
    .data_o         (Alu_input_1)
);

MUX3 Alu_input_2_MUX(
    .data1_i        (EX_RS2_data),
    .data2_i        (WB_Wr_data), 
    .data3_i        (MEM_Alu_result),
    .select_i       (forward_b),
    .data_o         (Alu_input_2_data)
);

MUX32 Alu_input_2_final_MUX(
    .data1_i        (Alu_input_2_data),
    .data2_i        (EX_imm), 
    .select_i       (EX_ALUSrc),  
    .data_o         (Alu_input_2)
);

ALU u_ALU(
    .data1_i        (Alu_input_1),
    .data2_i        (Alu_input_2),
    .ALUCtrl_i      (ALU_Ctrl),
    .data_o         (EX_Alu_result)
);

ALU_Control u_ALU_Control(
    .func_i         (EX_func), // [9:3] = funct7, [2:0] = funct3
    .ALUOp_i        (EX_ALUOp),
    .ALUCtrl_o      (ALU_Ctrl)
);

EX_MEM u_EX_MEM(
    .clk_i          (clk_i),
    .rst_n          (rst_n),

    .Regwrite_i     (EX_RegWrite),
    .MemtoReg_i     (EX_MemtoReg),
    .MemRead_i      (EX_MemRead),
    .MemWrite_i     (EX_MemWrite),
    .Alu_result_i   (EX_Alu_result),
    .rs2_data_i     (Alu_input_2_data),
    .rd_addr_i      (EX_Rd_addr),

    .Regwrite_o     (MEM_RegWrite),
    .MemtoReg_o     (MEM_MemtoReg),
    .MemRead_o      (MEM_MemRead),
    .MemWrite_o     (MEM_MemWrite),
    .Alu_result_o   (MEM_Alu_result),
    .rs2_data_o     (MEM_data_i),
    .rd_addr_o      (MEM_addr)
);



MUX32 WB_MUX(
    .data1_i        (WB_Alu_result),
    .data2_i        (WB_MEMData), 
    .select_i       (WB_MemtoReg),  
    .data_o         (WB_Wr_data)
);

Data_Memory u_Data_Memory(
    .clk_i          (clk_i),

    .addr_i         (MEM_Alu_result),
    .MemRead_i      (MEM_MemRead),
    .MemWrite_i     (MEM_MemWrite),
    .data_i         (MEM_data_i),
    .data_o         (MEM_data_o)
);

MEM_WB u_MEM_WB(
    .clk_i          (clk_i),
    .rst_n          (rst_n),

    .RegWrite_i     (MEM_RegWrite),
    .MemtoReg_i     (MEM_MemtoReg),
    .MemData_i      (MEM_data_o),
    .AluResult_i    (MEM_Alu_result),
    .Rd_addr_i      (MEM_addr),

    .RegWrite_o     (WB_RegWrite),
    .MemtoReg_o     (WB_MemtoReg),
    .MemData_o      (WB_MEMData),
    .AluResult_o    (WB_Alu_result),
    .Rd_addr_o      (WB_Rd_addr)
);

Hazard_detection u_Hazard_detection(
    .EX_MemRead_i       (EX_MemRead),
    .EX_RDaddr_i        (EX_Rd_addr),
    .ID_RS1addr_i       (ID_instr[19:15]),
    .ID_RS2addr_i       (ID_instr[24:20]),

    .PCWrite_o          (PcWrite),
    .Stall_o            (ID_Stall),
    .NoOp_o             (NoOp)
);

Forwarding_Unit u_Forwarding_Unit(
    .EX_RS1addr_i      (EX_RS1_addr),
    .EX_RS2addr_i      (EX_RS2_addr),
    .MEM_RDaddr_i      (MEM_addr),
    .WB_RDaddr_i       (WB_Rd_addr),
    .MEM_RegWrite_i    (MEM_RegWrite),
    .WB_RegWrite_i     (WB_RegWrite),

    .ForwardA_o       (forward_a),
    .ForwardB_o       (forward_b)
);

endmodule

