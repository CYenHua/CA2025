module ALU
(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o
);

// Ports
input   [31:0]      data1_i;
input   [31:0]      data2_i;
input   [2:0]       ALUCtrl_i;
output  [31:0]      data_o;

reg [31:0] data_o; 

localparam AND = 3'b000;
localparam XOR  = 3'b001;
localparam SLL   = 3'b010;
localparam ADD  = 3'b011;
localparam SUB  = 3'b100;
localparam MUL  = 3'b101;
localparam ADDI = 3'b110;
localparam SRAI  = 3'b111;


always @(*) begin
    case(ALUCtrl_i)
        AND: data_o = data1_i & data2_i;
        XOR: data_o = data1_i ^ data2_i;
        SLL: data_o = data1_i << data2_i[4:0];
        ADD: data_o = data1_i + data2_i;
        SUB: data_o = data1_i - data2_i;
        MUL: data_o = data1_i * data2_i;
        ADDI: data_o = data1_i + data2_i;
        SRAI: data_o = $signed(data1_i) >>> data2_i[4:0];
        default: data_o = 32'b0;
    endcase
end

endmodule

