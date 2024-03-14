`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 10:04:27 AM
// Design Name: 
// Module Name: testbench
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


module testbench();

bit CLK;
always #5 CLK = (CLK === 1'b0);

logic BTNL,BTNC;
logic [15:0] SWITCHES=0,LEDS;
logic [7:0] CATHODES;
logic [3:0] ANODES;

OTTER_Wrapper dut (.*);


// Initial Reset
initial begin
    BTNC = 1'b1;
    repeat (5) @(posedge CLK);
    BTNC = 1'b0;
end


endmodule
