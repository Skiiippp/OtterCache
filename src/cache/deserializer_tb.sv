`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/29/2024 09:29:39 AM
// Design Name: 
// Module Name: deserializer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module deserializer_tb();

    logic s_clk, s_in_write_ready, s_in_read_ready;
    logic [31:0] s_data_in;
    logic [255:0] s_data_out;
    
    logic [31:0] in_base = 32'h11111111;
    
    deserializer deser(s_clk, s_data_in, s_in_write_ready, s_in_read_ready, s_data_out);
    
    initial begin 
        s_clk = 0;
        s_in_write_ready = 0;
        s_in_read_ready = 0;
        s_data_in = in_base;
        
        #10
        
        // 1st test
        s_in_write_ready = 1;
        
        
        for(int i = 1; i < 8; i++) begin
            #10;
            s_in_write_ready = 0;
            s_data_in += in_base; 
        end
        
        #10;
        
        s_in_write_ready = 0;
        s_in_read_ready = 1;
        
        #10;
        
        s_in_read_ready = 0;
        
    end
    
    always #5 s_clk = ~s_clk;    // 10 ns clock

endmodule
