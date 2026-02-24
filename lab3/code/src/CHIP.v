//----------------------------- DO NOT MODIFY THE I/O INTERFACE!! ------------------------------//
module CPU #(                                                                                  //
    parameter BIT_W = 32                                                                        //
)(                                                                                              //
    // clock                                                                                    //
        input               i_clk,                                                              //
        input               i_rst_n,                                                            //
    // instruction memory                                                                       //
        input  [BIT_W-1:0]  i_IMEM_data,                                                        //
        output [BIT_W-1:0]  o_IMEM_addr,                                                        //
        output              o_IMEM_cen,                                                         //
    // data memory                                                                              //
        input               i_DMEM_stall,                                                       //
        input  [BIT_W-1:0]  i_DMEM_rdata,                                                       //
        output              o_DMEM_cen,                                                         //
        output              o_DMEM_wen,                                                         //
        output [BIT_W-1:0]  o_DMEM_addr,                                                        //
        output [BIT_W-1:0]  o_DMEM_wdata,                                                       //
    // finnish procedure                                                                        //
        output              o_finish,                                                           //
    // cache                                                                                    //
        input               i_cache_finish,                                                     //
        output              o_proc_finish                                                       //
);                                                                                              //
//----------------------------- DO NOT MODIFY THE I/O INTERFACE!! ------------------------------//


    wire        ctrl_reg_write;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rd_data;
    wire        reg_wen;

    assign reg_wen = ctrl_reg_write & ~i_DMEM_stall;
    assign o_IMEM_cen = 1'b1;

    Reg_file reg0(               
        .i_clk  (i_clk),             
        .i_rst_n(i_rst_n), 
        // input        
        .wen    (reg_wen),          
        .rs1    (i_IMEM_data[19:15]),                
        .rs2    (i_IMEM_data[24:20]),                
        .rd     (i_IMEM_data[11:7]),                 
        .wdata  (rd_data),             
        .rdata1 (rs1_data),           
        .rdata2 (rs2_data)
    );

    wire [1:0] mem_to_reg;
    wire       mem_read;
    wire       mem_write;
    wire [1:0] alu_op;
    wire       alu_src;
    wire       branch;
    wire       jump;

    wire [31:0] imm;

    Control control0(
        .opcode_i      (i_IMEM_data[6:0]),
        .RegWrite_o    (ctrl_reg_write),
        .MemtoReg_o    (mem_to_reg),
        .MemRead_o     (mem_read),
        .MemWrite_o    (mem_write),
        .ALUOp_o       (alu_op),
        .ALUSrc_o      (alu_src),
        .Branch_o      (branch),
        .jump_o        (jump)
    );

    Imm_Gen imm_gen0(
        .instr_i       (i_IMEM_data),
        .imm_o         (imm)
    );

    wire [31:0] alu_data2;
    MUX32 mux_data_2(
        .data1_i       (rs2_data),
        .data2_i       (imm),
        .select_i      (alu_src),
        .data_o        (alu_data2)
    );

    wire [2:0] alu_ctrl;

    ALU_Control alu_control0(
        .func_i         ({i_IMEM_data[31:25], i_IMEM_data[14:12]}),
        .ALUOp_i       (alu_op),
        .ALUCtrl_o     (alu_ctrl)
    );

    wire [31:0] alu_result;
    wire [31:0] alu_data1;
    assign alu_data1 = (i_IMEM_data[6:0] == 7'b0010111) ? PC : rs1_data; 
    wire zero_flag;
    ALU alu0(
        .data1_i       (alu_data1),
        .data2_i       (alu_data2),
        .ALUCtrl_i     (alu_ctrl),
        .data_o        (alu_result),
        .zero_o        (zero_flag)
    );

    wire [31:0] branch_addr;
    wire        branch_taken;
    Branch_Unit branch_unit0(
        .pc_i          (PC),
        .imm_i         (imm),
        .branch_i      (branch),
        .alu_result_i  (alu_result),
        .alu_zero_i    (zero_flag),
        .func3_i       (i_IMEM_data[14:12]),
        .branch_addr_o (branch_addr),
        .branch_taken_o (branch_taken)
    );

    assign rd_data = (mem_to_reg == 2'b00) ? alu_result :
                     (mem_to_reg == 2'b01) ? i_DMEM_rdata :
                     (mem_to_reg == 2'b10) ? PC + 4 : 32'b0;

    assign o_proc_finish = (i_IMEM_data[6:0] == 7'b1110011) ? 1'b1 : 1'b0;
    assign o_finish = i_cache_finish;

    assign o_DMEM_addr  = alu_result;   
    assign o_DMEM_wdata = rs2_data;     
    assign o_DMEM_wen   = mem_write;    
    assign o_DMEM_cen   = mem_read | mem_write;


// -------------------------------------------------------
// PC part
// -------------------------------------------------------
    reg [BIT_W-1:0] PC;
    wire [BIT_W-1:0] PC_next;


    wire is_jalr = (i_IMEM_data[6:0] == 7'b1100111);
    assign PC_next = is_jalr ? alu_result :
                     (branch_taken || (jump && !is_jalr)) ? branch_addr :
                     PC + 4;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            PC <= 32'h00010000; // Do not modify this value!!!
        end
        else begin
            if(i_DMEM_stall) begin
                PC <= PC; 
            end
            else begin
            PC <= PC_next;
            end
        end
    end
    assign o_IMEM_addr = PC;

endmodule

