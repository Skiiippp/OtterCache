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
        WB_WAIT_RESP,
        WB_WAIT_WRITE,
        FETCH_CPU,
        FETCH_MMEM,
        MEM_WAIT_RESP,
        MEM_WAIT_READ,
        READ_WAIT,
        ERROR
    } mem_state_t;

    mem_state_t state = IDLE, next_state;

    logic _wrrd_state;  // 0 - write, 1 read

    // ** FSM **
    always_ff @(posedge clk) begin 
        state <= next_state;
        if(rst) begin 
            _wrrd_state = 0;
        end 
    end
    
    always_comb begin 
        load_data_bytes_a = 1'b0;
        load_data_bytes_b = 1'b0;
        load_data_lines_a = 1'b0;
        load_data_lines_b = 1'b0;
        cpu_mem_valid = 1'b0;
        load_data_a = 1'b0;
        load_data_b = 1'b0;
        lru_load = 1'b0;
        load_tag_a = 1'b0;  
        load_tag_b = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        data_in_select = 1'b0;
        error = 1'b0;
        set_dirty = 2'b0;
        write_dirty = 2'b0;
        set_valid = 2'b0;
        write_valid = 2'b0;

        if(rst) next_state = IDLE;
        else begin
            error = 1'b0;
            case (state)
                IDLE: begin
                    _wrrd_state = 1'b0; // Reset this val basically
                    if(cpu_write)next_state <= WR_CHECK;
                    else if(cpu_read) next_state <= RD_CHECK;
                    else            next_state <= IDLE;
                end
                WR_CHECK: begin
                    if(hit && (is_valid[0] || is_valid[1])) begin    // valid hit
                        lru_load = 1'b1;
                        cpu_mem_valid = 1'b1;
                        next_state <= IDLE;
                    end else begin
                        _wrrd_state = 1'b0; 
                        next_state <= WB_CHECK;
                    end 
                end
                RD_CHECK: begin 
                    if(hit && (is_valid[0] || is_valid[1])) begin  // valid hit
                        lru_load = 1'b1;
                        cpu_mem_valid = 1'b1;
                        next_state <= IDLE;
                    end else begin
                        _wrrd_state = 1'b1; 
                        next_state <= WB_CHECK;
                    end
                end
                WB_CHECK: begin // Need to get data from cache to main mem
                    if(!is_dirty[lru_out] || !is_valid[lru_out]) begin  // lru_out = 1'b0 - Way A is LRU
                        next_state <= FETCH_MMEM;
                    end else begin          // eq. VALID & DIRTY - begin writing to mem
                        mem_write = 1'b1;
                        next_state <= WB_WAIT_RESP;
                    end
                end
                WB_WAIT_RESP: begin 
                    if(!ca_resp)    next_state <= WB_WAIT_RESP;   // Again, ca_resp not in block diagram but should be added
                    else begin            
                        next_state <= FETCH_MMEM;
                    end
                    mem_write = 1'b1;
                end
                WB_WAIT_WRITE: begin 
                    if(ca_resp) begin
                        next_state <= WB_WAIT_WRITE; 
                        mem_write = 1'b1;
                    end else begin            
                        next_state <= FETCH_MMEM;
                    end
                end
                FETCH_MMEM: begin   // Writing to cache from main mem
                    mem_read = 1'b1;
                    next_state <= MEM_WAIT_RESP;
                end
                MEM_WAIT_RESP: begin
                    if(!ca_resp) next_state <= MEM_WAIT_RESP;
                    else next_state <= MEM_WAIT_READ;
                    mem_read = 1'b1;
                end
                MEM_WAIT_READ: begin 
                    mem_read = 1'b1;
                    if(ca_resp) begin 
                        next_state <= MEM_WAIT_READ;
                    end else begin
                        if(!lru_out)    load_data_lines_a = 1'b1;
                        else            load_data_lines_b = 1'b1;
                        if(!_wrrd_state) begin 
                            next_state <= FETCH_CPU;
                        end else begin 
                            data_in_select = 1'b1; // Mem data
                            set_dirty[lru_out] = 1'b0;
                            write_dirty[lru_out] = 1'b1;
                            set_valid[lru_out] = 1'b1;
                            write_valid[lru_out] = 1'b1;
                            if(!lru_out) begin  // Way A
                                load_data_a = 1'b1;
                                load_tag_a = 1'b1;
                            end else begin      // Way B
                                load_data_b = 1'b1;
                                load_tag_b = 1'b1;
                            end
                            next_state <= READ_WAIT;
                        end
                    end
                end
                READ_WAIT: begin
                    if(!lru_out)    load_data_lines_a = 1'b1;
                    else            load_data_lines_b = 1'b1;
                    data_in_select = 1'b1;
                    next_state <= RD_CHECK;
                end
                FETCH_CPU: begin    // Writing to cache from CPU
                    data_in_select = 1'b0; // CPU data
                    set_dirty[lru_out] = 1'b1;
                    write_dirty[lru_out] = 1'b1;
                    set_valid[lru_out] = 1'b1;
                    write_valid[lru_out] = 1'b1;
                    if(!lru_out) begin  // Way A
                        load_data_a = 1'b1;
                        load_tag_a = 1'b1;
                        load_data_bytes_a = 1'b1;
                    end else begin      // Way B
                        load_data_b = 1'b1;
                        load_tag_b = 1'b1;
                        load_data_bytes_b = 1'b1;
                    end
                    next_state <= WR_CHECK;  // Will hit/miss logic still work?
                end
                ERROR: begin 
                    next_state <= IDLE;
                    error = 1'b1;
                end
                default: begin 
                    next_state <= ERROR;
                end
            endcase
        end
    end




endmodule