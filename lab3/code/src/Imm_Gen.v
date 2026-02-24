module Imm_Gen
(
    instr_i,
    imm_o
);

// Ports
input   [31:0]      instr_i;
output  [31:0]      imm_o;

localparam OP_I_TYPE = 7'b0010011;
localparam OP_LW     = 7'b0000011;
localparam OP_SW     = 7'b0100011;
localparam OP_Branch = 7'b1100011;
localparam OP_JAL    = 7'b1101111;
localparam OP_JALR   = 7'b1100111;
localparam OP_AUIPC  = 7'b0010111;

reg [31:0] imm_o;

always @(*) begin
    case(instr_i[6:0])
        OP_I_TYPE, OP_LW, OP_JALR: begin
            imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
        end
        OP_SW: begin
            imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        end
        OP_Branch: begin
            imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        end
        OP_JAL: begin
            imm_o = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
        end
        
        default: begin
            imm_o = 32'b0;
        end
    endcase
end

endmodule
