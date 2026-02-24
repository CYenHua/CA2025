module ALU_Control
(
    func_i,
    ALUOp_i,
    ALUCtrl_o
);

// Ports
input   [9:0]   func_i;  // [9:3] = funct7, [2:0] = funct3
input   [1:0]   ALUOp_i;
output  [2:0]   ALUCtrl_o;

reg     [2:0]   ALUCtrl_o;

localparam AND = 3'b000;
localparam XOR  = 3'b001;
localparam SLL   = 3'b010;
localparam ADD  = 3'b011;
localparam SUB  = 3'b100;
localparam MUL  = 3'b101;
localparam ADDI = 3'b110;
localparam SRAI  = 3'b111;

always @(*) begin
    case(ALUOp_i)
        2'b00: begin //i-type 
            if(func_i[2:0] == 3'b000) ALUCtrl_o = ADDI; 
            else ALUCtrl_o = SRAI; 
        end

        2'b01: begin 
            case(func_i)
                10'b0000000_111: ALUCtrl_o = AND; 
                10'b0000000_100: ALUCtrl_o = XOR;
                10'b0000000_001: ALUCtrl_o = SLL;
                10'b0000000_000: ALUCtrl_o = ADD;
                10'b0100000_000: ALUCtrl_o = SUB;
                10'b0000001_000: ALUCtrl_o = MUL;
                default: ALUCtrl_o = ADD;
            endcase
        end
        default: ALUCtrl_o = ADD;
    endcase
end

endmodule

