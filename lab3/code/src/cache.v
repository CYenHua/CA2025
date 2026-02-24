module Cache#(
        parameter BIT_W = 32,
        parameter ADDR_W = 32
    )(
        input i_clk,
        input i_rst_n,
        // processor interface
            input i_proc_cen,
            input i_proc_wen,
            input [ADDR_W-1:0] i_proc_addr,
            input [BIT_W-1:0]  i_proc_wdata,
            output [BIT_W-1:0] o_proc_rdata,
            output o_proc_stall,
            input i_proc_finish,
            output o_cache_finish,
        // memory interface
            output o_mem_cen,
            output o_mem_wen,
            output [ADDR_W-1:0] o_mem_addr,
            output [BIT_W*4-1:0]  o_mem_wdata,
            input [BIT_W*4-1:0] i_mem_rdata,
            input i_mem_stall,
            output o_cache_available,
        // others
        input  [ADDR_W-1: 0] i_offset
    );

    assign o_cache_available = 1;


    localparam CACHE_SIZE = 7; 
    
    localparam INDEX_BITS = $clog2(CACHE_SIZE); 
    
    localparam TAG_BITS = 28; 
    
    localparam CACHE_LINE_W = 1 + 1 + TAG_BITS + BIT_W*4; // valid + dirty + tag + data block


    wire [ADDR_W-1:0] addr_norm;      
    wire [ADDR_W-1:0] block_addr_num; 
    
    wire [TAG_BITS-1:0] req_tag;
    wire [INDEX_BITS-1:0] req_index;
    
    wire [1:0] block_offset; 

    reg [CACHE_LINE_W-1:0] cache_r [0:CACHE_SIZE-1];


    assign addr_norm = i_proc_addr - i_offset;
    
    
    assign block_offset = addr_norm[3:2];

    assign req_tag   = block_addr_num / CACHE_SIZE; 
    assign req_index = block_addr_num % CACHE_SIZE; 

    //------------------------------------------//
    // FSM Definition
    //------------------------------------------//
    localparam S_IDLE      = 2'b00;
    localparam S_ALLOCATE  = 2'b01;
    localparam S_WRITEBACK = 2'b10;
    localparam S_FLUSH     = 2'b11;

    reg [1:0] state, next_state;

    wire [CACHE_LINE_W-1:0] current_line;
    wire valid_bit;
    wire dirty_bit;
    wire [TAG_BITS-1:0] stored_tag; 
    wire [BIT_W*4-1:0] stored_data; 

    wire hit;
    wire miss;

    reg [INDEX_BITS:0] flush_idx; 
    wire flush_dirty;

 
    assign current_line = cache_r[req_index];
    assign valid_bit    = current_line[CACHE_LINE_W-1];
    assign dirty_bit    = current_line[CACHE_LINE_W-2];
    assign stored_tag   = current_line[CACHE_LINE_W-3 -: TAG_BITS];
    assign stored_data  = current_line[BIT_W*4-1:0];

    assign hit  = valid_bit && (stored_tag == req_tag);
    assign miss = !hit;


    assign flush_dirty = (flush_idx < CACHE_SIZE) ? cache_r[flush_idx][CACHE_LINE_W-2] : 1'b0;
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= S_IDLE;
        end 
        else begin
            state <= next_state;
        end
    end

    //------------------------------------------//
    // FSM: Next State Logic
    //------------------------------------------//
    always @(*) begin
        case(state)
            S_IDLE: begin
                if (i_proc_finish) begin
                    next_state = S_FLUSH; 
                end
                else if (i_proc_cen && miss) begin 
                    if (dirty_bit) begin
                        next_state = S_WRITEBACK;
                    end 
                    else begin
                        next_state = S_ALLOCATE;
                    end
                end
                else begin
                    next_state = S_IDLE;
                end
            end
            S_ALLOCATE: begin
                if (!i_mem_stall) begin 
                    next_state = S_IDLE;
                end
                else begin
                    next_state = S_ALLOCATE;
                end
            end
            S_WRITEBACK: begin
                if (!i_mem_stall) begin
                    next_state = S_ALLOCATE;
                end
                else begin
                    next_state = S_WRITEBACK;
                end
            end
            S_FLUSH: begin
                next_state = S_FLUSH; 
            end
            default: next_state = S_IDLE;
        endcase
    end

    //------------------------------------------//
    // Output Logic & Address Reconstruction
    //------------------------------------------//
    reg mem_cen, mem_wen;
    reg [ADDR_W-1:0] mem_addr;
    reg [BIT_W*4-1:0] mem_wdata;
    
    reg [31:0] recover_block_addr; 

    always @(*) begin
        mem_cen = 0;
        mem_wen = 0; 
        mem_addr = 0;
        mem_wdata = 0;
        recover_block_addr = 0;

        case(state)
            S_IDLE: begin
            end
            
            S_ALLOCATE: begin
                mem_cen = 1; 
                mem_wen = 0; 
                recover_block_addr = (req_tag * CACHE_SIZE) + req_index;
                mem_addr = (recover_block_addr << 4) + i_offset;
            end
            
            S_WRITEBACK: begin
                mem_cen = 1; 
                mem_wen = 1; 
                
                recover_block_addr = (stored_tag * CACHE_SIZE) + req_index;
                mem_addr = (recover_block_addr << 4) + i_offset;

                mem_wdata = stored_data; 
            end
            
            S_FLUSH: begin
                if(flush_dirty && flush_idx < CACHE_SIZE) begin
                    mem_cen = 1;
                    mem_wen = 1;
                    
                    recover_block_addr = (cache_r[flush_idx][CACHE_LINE_W-3 -: TAG_BITS] * CACHE_SIZE) + flush_idx;
                    mem_addr = (recover_block_addr << 4) + i_offset;

                    mem_wdata = cache_r[flush_idx][BIT_W*4-1:0];
                end
            end
            default: begin
            end
        endcase
    end

    // Connect outputs
    assign o_mem_cen = mem_cen;
    assign o_mem_wen = mem_wen;
    assign o_mem_addr = mem_addr;
    assign o_mem_wdata = mem_wdata;

    assign o_proc_stall = (state != S_IDLE) || (i_proc_cen && miss);
    assign o_proc_rdata = stored_data[block_offset*BIT_W +: BIT_W];

    // Finish Condition
    assign o_cache_finish = (state == S_FLUSH) && (flush_idx >= CACHE_SIZE-1) && (!flush_dirty);

    //------------------------------------------//
    // Cache Update Logic
    //------------------------------------------//
    integer i;
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                cache_r[i] <= 0;  
            end
            flush_idx <= 0; 
        end    
        else begin
            case(state)
                S_IDLE: begin
                    flush_idx <= 0;
                    if (i_proc_cen && i_proc_wen && hit) begin
                        cache_r[req_index][CACHE_LINE_W-2] <= 1'b1; 
                        cache_r[req_index][(block_offset*BIT_W) +: BIT_W] <= i_proc_wdata;
                    end 
                end
                
                S_ALLOCATE: begin
                    if (!i_mem_stall) begin
                        cache_r[req_index][CACHE_LINE_W-1] <= 1'b1;    // Valid
                        cache_r[req_index][CACHE_LINE_W-2] <= 1'b0;    // Clean 
                        cache_r[req_index][CACHE_LINE_W-3 -: TAG_BITS] <= req_tag; 
                        cache_r[req_index][BIT_W*4-1:0] <= i_mem_rdata; 
                    end
                end
                
                S_WRITEBACK: begin
                end
                
                S_FLUSH: begin
                    if(flush_dirty && flush_idx < CACHE_SIZE) begin
                        if(!i_mem_stall) begin
                            cache_r[flush_idx][CACHE_LINE_W-2] <= 1'b0; // Clean
                            if (flush_idx < CACHE_SIZE)
                                flush_idx <= flush_idx + 1;
                        end
                    end
                    else begin
                        if (flush_idx < CACHE_SIZE)
                            flush_idx <= flush_idx + 1;
                    end
                end
                default: ;
            endcase
        end
    end
    
endmodule