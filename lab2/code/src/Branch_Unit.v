module Branch_Unit
(
    pc_i,
    branch_i,
    rs1_data_i,
    rs2_data_i,
    imm_i,
    func3_i,
    
    branch_addr_o,
    branch_taken_o
);

// Ports
input   [31:0]  pc_i;
input           branch_i;
input   [31:0]  rs1_data_i;
input   [31:0]  rs2_data_i; 
input   [31:0]  imm_i;
input   [2:0]   func3_i;

output  [31:0]  branch_addr_o;
output          branch_taken_o;


assign branch_addr_o = pc_i + (imm_i << 1);

assign equal = (rs1_data_i == rs2_data_i);

assign branch_taken_o = (branch_i && ((func3_i == 3'b000 && equal) | (func3_i == 3'b001 & ~equal)));

endmodule