module EX_MEM
(
    clk_i,
    rst_n,

    Regwrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,

    Alu_result_i,
    rs2_data_i,
    rd_addr_i,

    Regwrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    Alu_result_o,
    rs2_data_o,
    rd_addr_o,
);

// Ports
input               clk_i;
input               rst_n;

input               Regwrite_i;
input               MemtoReg_i;
input               MemRead_i;
input               MemWrite_i;
input   [31:0]      Alu_result_i;
input   [31:0]      rs2_data_i;
input   [4:0]       rd_addr_i;

output reg          Regwrite_o;
output reg          MemtoReg_o;
output reg          MemRead_o;
output reg          MemWrite_o;
output reg [31:0]   Alu_result_o;
output reg [31:0]   rs2_data_o;
output reg [4:0]    rd_addr_o;


always @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
        Regwrite_o      <= 1'b0;
        MemtoReg_o      <= 1'b0;
        MemRead_o       <= 1'b0;
        MemWrite_o      <= 1'b0;
        Alu_result_o    <= 32'b0;
        rs2_data_o      <= 32'b0;
        rd_addr_o       <= 5'b0;
    end
    else begin
        Regwrite_o      <= Regwrite_i;
        MemtoReg_o      <= MemtoReg_i;
        MemRead_o       <= MemRead_i;
        MemWrite_o      <= MemWrite_i;
        Alu_result_o    <= Alu_result_i;
        rs2_data_o      <= rs2_data_i;
        rd_addr_o       <= rd_addr_i;
    end
end

endmodule