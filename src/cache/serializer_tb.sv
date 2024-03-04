`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2024 08:17:56 PM
// Design Name: 
// Module Name: serializer_tb
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


module serializer_tb();

    logic s_clk, s_in_write_ready, s_in_read_ready;
    logic [255:0] s_data_in;
    logic [31:0] s_data_out;
    
    serializer ser(s_clk, s_data_in, s_in_write_ready, s_in_read_ready, s_data_out);
    
    initial begin 
        s_clk = 0;
        s_in_write_ready = 0;
        s_in_read_ready = 0;
        s_data_out = 0;
        s_data_in = 256'h1111111122222222333333334444444455555555666666667777777788888888;
        #10
        
        // 1st test
        s_in_write_ready = 1;
        
        #10;
        
        s_in_write_ready = 0;
        s_in_read_ready = 1;
        
        #10;
        
        s_in_read_ready = 0;
        
        #80
        
        // 2nd test
        s_in_write_ready = 1;
        
        #10;
        
        s_in_write_ready = 0;
        s_in_read_ready = 1;
        
        #10;
        
        s_in_read_ready = 0;
        
        
        
        
    end
    
    always #5 s_clk = ~s_clk;    // 10 ns clock

endmodule
