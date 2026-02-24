module ID_EX
(
    clk_i,
    rst_n,

    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    ALUOp_i,
    ALUSrc_i,

    rs1_data_i,
    rs2_data_i,
    imm_i,
    func_i,

    rs1_addr_i,
    rs2_addr_i,
    rd_addr_i,


    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    rs1_data_o,
    rs2_data_o,
    imm_o,
    func_o,
    rs1_addr_o,
    rs2_addr_o,
    rd_addr_o
);

input               clk_i;
input               rst_n;
input               RegWrite_i;
input               MemtoReg_i;
input               MemRead_i;
input               MemWrite_i;
input   [1:0]       ALUOp_i;
input               ALUSrc_i;

input   [31:0]      rs1_data_i;
input   [31:0]      rs2_data_i;
input   [31:0]      imm_i;
input   [9:0]       func_i;
input   [4:0]       rs1_addr_i;
input   [4:0]       rs2_addr_i;
input   [4:0]       rd_addr_i;

output  reg         RegWrite_o;
output  reg         MemtoReg_o;
output  reg         MemRead_o;
output  reg         MemWrite_o;
output  reg [1:0]   ALUOp_o;
output  reg         ALUSrc_o;
output  reg [31:0]  rs1_data_o;
output  reg [31:0]  rs2_data_o;
output  reg [31:0]  imm_o;
output  reg [9:0]   func_o;
output  reg [4:0]   rs1_addr_o;
output  reg [4:0]   rs2_addr_o;
output  reg [4:0]   rd_addr_o;

always @(posedge clk_i or negedge rst_n) begin
    if(!rst_n) begin
        RegWrite_o <= 1'b0;
        MemtoReg_o <= 1'b0;
        MemRead_o <= 1'b0;
        MemWrite_o <= 1'b0;
        ALUOp_o <= 2'b00;
        ALUSrc_o <= 1'b0;
        rs1_data_o <= 32'b0;
        rs2_data_o <= 32'b0;
        imm_o <= 32'b0;
        func_o <= 10'b0;
        rs1_addr_o <= 5'b0;
        rs2_addr_o <= 5'b0;
        rd_addr_o <= 5'b0;
    end
    else begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        MemRead_o <= MemRead_i;
        MemWrite_o <= MemWrite_i;
        ALUOp_o <= ALUOp_i;
        ALUSrc_o <= ALUSrc_i;
        rs1_data_o <= rs1_data_i;
        rs2_data_o <= rs2_data_i;
        imm_o <= imm_i;
        func_o <= func_i;
        rs1_addr_o <= rs1_addr_i;
        rs2_addr_o <= rs2_addr_i;
        rd_addr_o <= rd_addr_i;
    end
end 
endmodule