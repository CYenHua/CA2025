module IF_ID
(
    clk_i,
    rst_n,

    stall_i,
    flush_i,
    pc_i,
    instr_i,
    
    pc_o,
    instr_o
);

// Ports
input               clk_i;
input               rst_n;
input               stall_i;
input               flush_i;
input   [31:0]      pc_i;
input   [31:0]      instr_i;

output reg [31:0]   pc_o;
output reg [31:0]   instr_o;

    
always @(posedge clk_i or negedge rst_n) begin
    if(~rst_n) begin
        pc_o <= 32'b0;
        instr_o <= 32'b0;
    end
    else if (flush_i) begin
        pc_o <= 32'b0;
        instr_o <= 32'b0;
    end
    else if (~stall_i) begin
        pc_o <= pc_i;
        instr_o <= instr_i;
    end
end

    
endmodule