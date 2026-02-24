module ALU
(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
    zero_o
);

// Ports
input   [31:0]      data1_i;
input   [31:0]      data2_i;
input   [2:0]       ALUCtrl_i;
output  [31:0]      data_o;
output              zero_o;

reg [31:0] data_o; 

localparam AND = 3'b000;
localparam XOR  = 3'b001;
localparam SLL   = 3'b010;
localparam ADD  = 3'b011;
localparam SUB  = 3'b100;
localparam MUL  = 3'b101;
localparam SLT  = 3'b110;
localparam SRAI  = 3'b111;


always @(*) begin
    data_o = 32'b0;
    case(ALUCtrl_i)
        AND: data_o = data1_i & data2_i;
        XOR: data_o = data1_i ^ data2_i;
        SLL: data_o = data1_i << data2_i[4:0];
        ADD: data_o = data1_i + data2_i;
        SUB: data_o = data1_i - data2_i;
        MUL: data_o = data1_i * data2_i;
        SLT:  data_o = (data1_i < data2_i) ? 32'd1 : 32'd0; 
        SRAI: data_o = $signed(data1_i) >>> data2_i[4:0];
        default: data_o = 32'b0;
    endcase
end

assign zero_o = (data_o == 32'b0) ? 1'b1 : 1'b0;
endmodule

