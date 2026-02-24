module Hazard_detection
(
    EX_MemRead_i,
    EX_RDaddr_i,
    ID_RS1addr_i,
    ID_RS2addr_i,

    PCWrite_o,
    Stall_o,
    NoOp_o
);
// Ports
input          EX_MemRead_i;
input  [4:0]   EX_RDaddr_i;
input  [4:0]   ID_RS1addr_i;
input  [4:0]   ID_RS2addr_i; 

output          PCWrite_o;
output          Stall_o;
output          NoOp_o;

reg             PCWrite_o;
reg             Stall_o;
reg             NoOp_o;

always @(*) begin
    PCWrite_o = 1;
    Stall_o = 0;
    NoOp_o = 0;

    if(EX_MemRead_i && EX_RDaddr_i != 0 && (EX_RDaddr_i == ID_RS1addr_i || EX_RDaddr_i == ID_RS2addr_i)) begin
        PCWrite_o = 0;
        Stall_o = 1;
        NoOp_o = 1;
    end

end

endmodule