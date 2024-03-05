`timescale 1ns / 1ps
module control_tb();

    // inputs
    logic clk, rst, cpu_read, cpu_write, lru_out, ca_resp, hit;
    logic [1:0] is_dirty, is_valid;

    // outputs
    logic cpu_mem_valid, load_data_a, load_data_b, lru_load, load_tag_a,
        load_tag_b, mem_read, mem_write, data_in_select, error;
    logic [1:0] set_dirty, write_dirty, set_valid, write_valid;

    cache_control ca(clk, rst, cpu_read, cpu_write, lru_out, ca_resp, hit,
                    is_dirty, is_valid, cpu_mem_valid, load_data_a, load_data_b,
                    lru_load, load_tag_a, load_tag_b, mem_read, mem_write, 
                    data_in_select, error, set_dirty, write_dirty, set_valid, 
                    write_valid);
    
    initial clk = 0; always #5 clk = ~clk;  // 10ns period

    initial begin 
        rst = 1'b1; #10 rst = 1'b0;

        // *** verify write ***
        
        // hit
        cpu_write = 1'b1; is_valid = 2'b1; hit = 1'b1;
        #10 
        cpu_write = 1'b0;
        
        // miss
        cpu_write = 1'b1; is_valid = 2'b1; hit = 1'b0;

    end

endmodule