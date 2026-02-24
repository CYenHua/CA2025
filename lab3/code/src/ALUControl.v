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

localparam AND  = 3'b000;
localparam XOR  = 3'b001;
localparam SLL  = 3'b010;
localparam ADD  = 3'b011;
localparam SUB  = 3'b100;
localparam MUL  = 3'b101;
localparam SLT  = 3'b110;
localparam SRAI = 3'b111;


wire [2:0] funct3 = func_i[2:0];
wire [6:0] funct7 = func_i[9:3];


always @(*) begin
    ALUCtrl_o = 3'b000; 
    case(ALUOp_i)
        2'b00: begin 
            ALUCtrl_o = ADD;
        end

        2'b01: begin //branch
            ALUCtrl_o = SUB;
        end

        2'b10: begin //R-type
            case(funct3)
                3'b000: begin
                    if(funct7 == 7'b0000000) ALUCtrl_o = ADD;                         
                    else if(funct7 == 7'b0100000) ALUCtrl_o = SUB;  
                    else if(funct7 == 7'b0000001) ALUCtrl_o = MUL;                      
                    else ALUCtrl_o = ADD; 
                end

                3'b111: ALUCtrl_o = AND; 
                3'b100: ALUCtrl_o = XOR;  
                // 3'b001: ALUCtrl_o = SLL; 
                default: begin
                end
            endcase
        end

        2'b11: begin //I-type
            case(funct3)
                3'b000: ALUCtrl_o = ADD; //addi
                3'b001: ALUCtrl_o = SLL; //slli
                3'b010: ALUCtrl_o = SLT; //slti
                3'b101: ALUCtrl_o = SRAI; //srai

                default: begin end 
            endcase
        end

    default: begin
    end
    endcase
end

endmodule

