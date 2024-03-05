module cache_fsw(
    input logic 
        clk, 
        rst, 
        cpu_read, 
        cpu_write, 
        lru_out, 
        ca_resp,    // Not currently in block diagram or ca
        hit,
    input logic [1:0] 
        is_dirty,
        is_valid,
    output logic
        cpu_mem_valid,
        load_data_a,
        load_data_b,
        lru_load,
        load_tag_a,
        load_tag_b,
        mem_read,
        mem_write,
        data_in_select,
        error,   // Not in block diagram, just for debugging
    output logic [1:0] 
        set_dirty,
        write_dirty,
        set_valid,
        write_valid
);

    // ** DEFS **
    typedef enum {
        IDLE,
        WR_CHECK,
        RD_CHECK,
        WRITEBACK,
        WB_WAIT,
        FETCH_CPU,
        FETCH_MMEM,
        ERROR
    } mem_state_t;

    mem_state_t state;

    logic _wrrd_state;  // 0 - write, 1 read

    // ** FSM **
    initial state = IDLE; // initial state is idle
    always @(posedge clk) begin
        cpu_mem_valid <= 1'b0;
        load_data_a <= 1'b0;
        load_data_b <= 1'b0;
        lru_load <= 1'b0;
        load_tag_a <= 1'b0;
        load_tag_b <= 1'b0;
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        data_in_select <= 1'b0;
        error <= 1'b0;
        set_dirty = 2'b0;
        write_dirty = 2'b0;
        set_valid = 2'b0;
        write_valid = 2'b0;

        if(rst) state <= IDLE;
        else begin
            error <= 1'b0;
            case (state)
                IDLE: begin
                    _wrrd_state = 1'b0; // Reset basically
                    if(cpu_write)state <= WR_CHECK;
                    else if(cpu_read) state <= RD_CHECK;
                    else            state <= IDLE;
                end
                WR_CHECK: begin
                    if(hit && (is_valid[0] || is_valid[1])) begin    // valid hit
                        lru_load <= 1'b1;
                        state <= IDLE;
                    end else begin
                        _wrrd_state = 1'b0; 
                        state <= WRITEBACK;
                    end 
                end
                RD_CHECK: begin 
                    if(hit && (is_valid[0] || is_valid[1])) begin  // valid hit
                        lru_load <= 1'b1;
                        cpu_mem_valid <= 1'b1;
                        state <= IDLE;
                    end else begin
                        _wrrd_state = 1'b1; 
                        state <= WRITEBACK;
                    end
                end
                WRITEBACK: begin // Need to get data from cache to main mem
                    if(!is_dirty[lru_out] || !is_valid[lru_out]) begin  // lru_out = 1'b0 - Way A is LRU
                        if(!_wrrd_state)    state <= FETCH_CPU;
                        else                state <= FETCH_MMEM;
                    end else begin          // eq. VALID & DIRTY - begin writing to mem
                        mem_write <= 1'b1;
                        state <= WB_WAIT;
                    end
                end
                WB_WAIT: begin 
                    mem_write <= 1'b0;
                    if(!ca_resp)    state <= WB_WAIT;   // Again, ca_resp not in block diagram but should be added
                    else begin            
                        if(!_wrrd_state)    state <= FETCH_CPU;     // Write
                        else                state <= FETCH_MMEM;    // Read
                    end
                end
                FETCH_CPU: begin    // Writing to cache from CPU
                    data_in_select <= 1'b0; // CPU data
                    set_dirty[lru_out] <= 1'b1;
                    write_dirty[lru_out] <= 1'b1;
                    set_valid[lru_out] <= 1'b1;
                    write_dirty[lru_out] <= 1'b1;
                    if(!lru_out) begin  // Way A
                        load_data_a <= 1'b1;
                        load_tag_a <= 1'b1;
                    end else begin      // Way B
                        load_data_a <= 1'b1;
                        load_tag_a <= 1'b1;
                    end
                end
                FETCH_MMEM: begin   // Writing to cache from main mem
                    
                end
                ERROR: begin 
                    state <= IDLE;
                    error <= 1'b1;
                end
                default: begin 
                    state <= ERROR;
                end
            endcase
        end
    end



endmodule