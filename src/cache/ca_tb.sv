`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2024 01:57:50 PM
// Design Name: 
// Module Name: ca_tb
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


module ca_tb();

    logic clk;

    initial clk = 0; always #5 clk = ~clk;

    mem_itf #(256) ca_itf(clk);
    mem_itf #(32) pmem_itf(clk);

    cacheline_adaptor ca(ca_itf, pmem_itf);


endmodule
