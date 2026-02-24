module Control
(
    opcode_i,

    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Branch_o,
    jump_o
);

// Ports
input   [6:0]   opcode_i;

output          RegWrite_o;
output  [1:0]   MemtoReg_o;
output          MemRead_o;
output          MemWrite_o;
output  [1:0]   ALUOp_o;
output          ALUSrc_o;
output          Branch_o;
output          jump_o;

reg             RegWrite_o;
reg     [1:0]   MemtoReg_o;
reg             MemRead_o;
reg             MemWrite_o;
reg     [1:0]   ALUOp_o;
reg             ALUSrc_o;
reg             Branch_o;
reg             jump_o;


always @(*) begin
    RegWrite_o = 1'b0;
    MemtoReg_o = 1'b00; //0: ALU, 1: Mem, 2: PC+4
    MemRead_o  = 1'b0;
    MemWrite_o = 1'b0;
    ALUOp_o    = 2'b00; // 00: Add, 01: Sub, 10: R-type, 11: I-type
    ALUSrc_o   = 1'b0;  // 0: Reg, 1: Imm
    Branch_o   = 1'b0;
    jump_o     = 1'b0;

    
    case(opcode_i)
        7'b0110011: begin // R-type
            ALUOp_o = 2'b10; 
            ALUSrc_o = 1'b0; 
            RegWrite_o = 1'b1; 
        end

        7'b0010011: begin // I-type
            ALUOp_o = 2'b11; 
            ALUSrc_o = 1'b1; 
            RegWrite_o = 1'b1; 
        end

        7'b0100011: begin // S-type
            ALUOp_o = 2'b00;
            ALUSrc_o = 1'b1;
            MemWrite_o = 1'b1;
        end

        7'b0000011: begin // Load
            ALUOp_o = 2'b00; 
            ALUSrc_o = 1'b1; 
            MemtoReg_o = 1'b01; 
            MemRead_o = 1'b1; 
            RegWrite_o = 1'b1; 
        end

        7'b1100011: begin // Branch
            ALUOp_o = 2'b01; 
            ALUSrc_o = 1'b0; 
            Branch_o = 1'b1; 
        end

        7'b1101111: begin // JAL
            ALUSrc_o = 1'b1;
            RegWrite_o = 1'b1;
            MemtoReg_o = 2'b10; // PC + 4
            jump_o = 1'b1;
        end

        7'b1100111: begin // JALR
            ALUSrc_o = 1'b1;
            RegWrite_o = 1'b1;
            MemtoReg_o = 2'b10; // PC + 4
            jump_o = 1'b1;
        end

        7'b0010111: begin // AUIPC : rd = PC + (imm << 12)
            ALUSrc_o = 1'b1;
            RegWrite_o = 1'b1;
        end



        default: begin
        end
    endcase
        
    


    
end

endmodule