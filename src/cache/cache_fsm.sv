module cache_fsw(
    input logic 
        clk, 
        rst, 
        cpu_read, 
        cpu_write, 
        lru_out, 
        hit,    // Can lru be used to determine which way was hit? I dont think so - might have to become bus
        [1:0] is_dirty,
        [1:0] is_valid,
        ca_resp,    // Not currently in block diagram or ca
    output logic
        cpu_mem_valid,
        load_data_a,
        load_data_b,
        lru_load,
        load_tag_a,
        load_tag_b,
        [1:0] set_dirty,
        [1:0] write_dirty,
        [1:0] set_valid,
        [1:0] write_valid,
        mem_read,
        mem_write,
        data_in_select,
        error   // Not in block diagram, just for debugging
);

    // ** DEFS **
    typedef enum {
        IDLE,
        WR_CHECK,
        RD_CHECK,
        WRITEBACK,
        WB_WAIT,
        CACHE_LOAD
    } mem_state_t;

    mem_state_t state;


    // ** FSM **
    initial state = IDLE; // initial state is idle
    always @(posedge clk) begin
        if(rst) state <= IDLE;
        else begin
            error <= 1'b0;
            case (state)
                IDLE: begin
                    if(cpu_write)   state <= WR_CHECK;
                    else if(cpu_rd) state <= RD_CHECK;
                    else            state <= IDLE;
                end
                WR_CHECK:
                RD_CHECK:
                WRITEBACK:
                WB_WAIT:
                CACHE_LOAD:
                default: begin 
                    state <= IDLE;
                    error <= 1'b1;
                end
            endcase
        end
    end



endmodule