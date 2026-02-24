module MEM_WB
(
    clk_i,
    rst_n,

    RegWrite_i,
    MemtoReg_i,
    AluResult_i,
    MemData_i,
    Rd_addr_i,

    RegWrite_o,
    MemtoReg_o,
    AluResult_o,
    MemData_o,
    Rd_addr_o
);

// Ports
input             clk_i;
input             rst_n; 
input             RegWrite_i;
input             MemtoReg_i;
input   [31:0]    AluResult_i;
input   [31:0]    MemData_i;
input   [4:0]     Rd_addr_i;

output reg        RegWrite_o;
output reg        MemtoReg_o;
output reg [31:0] AluResult_o;
output reg [31:0] MemData_o;
output reg [4:0]  Rd_addr_o;

always @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
        RegWrite_o   <= 1'b0;
        MemtoReg_o   <= 1'b0;
        AluResult_o  <= 32'b0;
        MemData_o    <= 32'b0;
        Rd_addr_o    <= 5'b0;
    end 
    else begin
        RegWrite_o   <= RegWrite_i;
        MemtoReg_o   <= MemtoReg_i;
        AluResult_o  <= AluResult_i;
        MemData_o    <= MemData_i;
        Rd_addr_o    <= Rd_addr_i;
    end
end
    
endmodule