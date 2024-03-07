module cache_control(
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
        load_data_bytes_a,
        load_data_bytes_b,
        load_data_lines_a,
        load_data_lines_b,
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
        WB_CHECK,
        WB_WAIT,
        FETCH_CPU,
        FETCH_MMEM,
        F_M_WAIT,
        ERROR
    } mem_state_t;

    mem_state_t state;

    logic _wrrd_state;  // 0 - write, 1 read

    int fmw_cnt = 0;

    // ** FSM **
    initial state = IDLE; // initial state is idle
    always @(posedge clk) begin
        load_data_bytes_a <= 1'b0;
        load_data_bytes_b <= 1'b0;
        load_data_lines_a <= 1'b0;
        load_data_lines_b <= 1'b0;
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
                    _wrrd_state = 1'b0; // Reset this val basically
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
                        state <= WB_CHECK;
                    end 
                end
                RD_CHECK: begin 
                    if(hit && (is_valid[0] || is_valid[1])) begin  // valid hit
                        lru_load <= 1'b1;
                        cpu_mem_valid <= 1'b1;
                        state <= IDLE;
                    end else begin
                        _wrrd_state = 1'b1; 
                        state <= WB_CHECK;
                    end
                end
                WB_CHECK: begin // Need to get data from cache to main mem
                    if(!is_dirty[lru_out] || !is_valid[lru_out]) begin  // lru_out = 1'b0 - Way A is LRU
                        if(!_wrrd_state)    state <= FETCH_CPU;
                        else                state <= FETCH_MMEM;
                    end else begin          // eq. VALID & DIRTY - begin writing to mem
                        mem_write <= 1'b1;
                        state <= WB_WAIT;
                    end
                end
                WB_WAIT: begin 
                    if(!ca_resp)    state <= WB_WAIT;   // Again, ca_resp not in block diagram but should be added
                    else begin            
                        state <= FETCH_MMEM;
                    end
                end
                FETCH_MMEM: begin   // Writing to cache from main mem
                    mem_read <= 1'b1;
                    state <= F_M_WAIT;
                end
                F_M_WAIT: begin     // should just wait 8 cycles
                    if(fmw_cnt < 8) begin 
                        fmw_cnt <= fmw_cnt + 1;
                        state <= F_M_WAIT;
                    end else begin
                        if(!lru_out)    load_data_lines_a <= 1'b1;
                        else            load_data_lines_b <= 1'b1;
                        if(!_wrrd_state) begin 
                            state <= FETCH_CPU;
                        end else begin 
                            fmw_cnt <= 0;
                            data_in_select <= 1'b1; // Mem data
                            set_dirty[lru_out] <= 1'b1;
                            write_dirty[lru_out] <= 1'b1;
                            set_valid[lru_out] <= 1'b1;
                            write_valid[lru_out] <= 1'b1;
                            if(!lru_out) begin  // Way A
                                load_data_a <= 1'b1;
                                load_tag_a <= 1'b1;
                            end else begin      // Way B
                                load_data_b <= 1'b1;
                                load_tag_b <= 1'b1;
                            end
                            state <= RD_CHECK;
                        end
                    end
                end
                FETCH_CPU: begin    // Writing to cache from CPU
                    data_in_select <= 1'b0; // CPU data
                    set_dirty[lru_out] <= 1'b1;
                    write_dirty[lru_out] <= 1'b1;
                    set_valid[lru_out] <= 1'b1;
                    write_valid[lru_out] <= 1'b1;
                    if(!lru_out) begin  // Way A
                        load_data_a <= 1'b1;
                        load_tag_a <= 1'b1;
                        load_data_bytes_a <= 1'b1;
                    end else begin      // Way B
                        load_data_b <= 1'b1;
                        load_tag_b <= 1'b1;
                        load_data_bytes_b <= 1'b1;
                    end
                    state <= WR_CHECK;  // Will hit/miss logic still work?
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