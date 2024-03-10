`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/29/2024 09:09:46 AM
// Design Name: 
// Module Name: deserializer
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


module deserializer(
    input logic clk,
    input logic [31:0] data_in,
    input logic in_write_ready,
    input logic in_read_ready,
    output logic [255:0] data_out
);

logic [7:0][31:0] write_regs;    // Blocks 7-0
int counter = 0; 
logic reg_enable, write_status, read_status;

assign read_status = in_read_ready;

always_comb begin
    if(!in_write_ready && !counter) write_status = 0;    // Not ready
    else                            write_status = 1;    // Ready
end


always_comb begin
    if (!write_status && !read_status)  reg_enable = 0;
    else                                reg_enable = 1;
end
    
always_ff @(posedge clk) begin
    if(reg_enable) begin    // either write or read is ready
        if (write_status) begin
            write_regs[7] <= data_in;
            write_regs[6] <= write_regs[7];
            write_regs[5] <= write_regs[6];
            write_regs[4] <= write_regs[5];
            write_regs[3] <= write_regs[4];
            write_regs[2] <= write_regs[3];
            write_regs[1] <= write_regs[2];
            write_regs[0] <= write_regs[1];
            counter <= counter + 1;
            if (counter > 6) counter <= 0;
        end else begin
            data_out[255:224] <= write_regs[7];
            data_out[223:192] <= write_regs[6];
            data_out[191:160] <= write_regs[5];
            data_out[159:128] <= write_regs[4];
            data_out[127:96] <= write_regs[3];
            data_out[95:64] <= write_regs[2];
            data_out[63:32] <= write_regs[1];
            data_out[31:0] <= write_regs[0];
        end
    end
end

endmodule
