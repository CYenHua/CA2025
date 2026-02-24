module Forwarding_Unit
(  
    EX_RS1addr_i,
    EX_RS2addr_i,
    MEM_RDaddr_i,
    WB_RDaddr_i,
    MEM_RegWrite_i,
    WB_RegWrite_i,

    ForwardA_o,
    ForwardB_o
);

// Ports
input  [4:0]     EX_RS1addr_i;
input  [4:0]     EX_RS2addr_i;
input  [4:0]     MEM_RDaddr_i;
input  [4:0]     WB_RDaddr_i;
input            MEM_RegWrite_i;
input            WB_RegWrite_i;

output reg [1:0] ForwardA_o;
output reg [1:0] ForwardB_o;

// Forwarding Unit
always @(*) begin
    ForwardA_o = 2'b00;
    ForwardB_o = 2'b00;

    if(MEM_RegWrite_i && (MEM_RDaddr_i != 5'b00000) && (MEM_RDaddr_i == EX_RS1addr_i)) begin
        ForwardA_o = 2'b10;
    end
    else if(WB_RegWrite_i && (WB_RDaddr_i != 5'b00000) && (WB_RDaddr_i == EX_RS1addr_i)) begin
        ForwardA_o = 2'b01;
    end

    if(MEM_RegWrite_i && (MEM_RDaddr_i != 5'b00000) && (MEM_RDaddr_i == EX_RS2addr_i)) begin
        ForwardB_o = 2'b10;
    end
    else if(WB_RegWrite_i && (WB_RDaddr_i != 5'b00000) && (WB_RDaddr_i == EX_RS2addr_i)) begin
        ForwardB_o = 2'b01;
    end

end

endmodule