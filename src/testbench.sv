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

logic RST;

OTTER_MCU Otter(.CLK(CLK), .RESET(RST));

initial begin
    RST = 1'b1;
    #10 
    RST = 1'b0;
end


endmodule
