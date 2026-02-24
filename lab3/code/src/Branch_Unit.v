module Branch_Unit
(
    pc_i,
    imm_i,
    branch_i,
    alu_result_i,
    alu_zero_i,
    func3_i,
    
    branch_addr_o,
    branch_taken_o
);

// Ports
input   [31:0]  pc_i;
input   [31:0]  imm_i;
input           branch_i;
input   [31:0]  alu_result_i;
input           alu_zero_i;
input   [2:0]   func3_i;

output  [31:0]  branch_addr_o;
output          branch_taken_o;


assign branch_addr_o = pc_i + imm_i;

reg take;
always @(*) begin
    case(func3_i)
        3'b000: take = alu_zero_i;        // BEQ
        3'b001: take = ~alu_zero_i;       // BNE
        3'b100: take = (alu_result_i[31] == 1'b1); // BLT
        3'b101: take = (alu_result_i[31] == 1'b0); // BGE
        default: take = 1'b0;
    endcase
end

assign branch_taken_o = branch_i && take;

endmodule