`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2024 11:01:10 AM
// Design Name: 
// Module Name: serializer
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


module serializer(
    input logic clk,
    input logic [255:0] data_in,
    input logic in_write_ready,
    input logic in_read_ready,
    output logic resp,
    output logic [31:0] data_out
);

logic [7:0][31:0] write_regs;    // Blocks 7-0
int counter = 0; 
logic reg_enable, write_status, read_status;

logic resp;

assign write_status = in_write_ready;

always_comb begin
    if(!in_read_ready && !counter)  read_status = 0;    // Not ready
    else                            read_status = 1;    // Ready
end


always_comb begin
    if (!write_status && !read_status)  reg_enable = 0;
    else                                reg_enable = 1;
end
    
always_ff @(posedge clk) begin
    resp <= 1'b0;
    if(reg_enable) begin    // either write or read is ready
        if (write_status) begin
            write_regs[7] <= data_in[255:224];
            write_regs[6] <= data_in[223:192];
            write_regs[5] <= data_in[191:160];
            write_regs[4] <= data_in[159:128];
            write_regs[3] <= data_in[127:96];
            write_regs[2] <= data_in[95:64];
            write_regs[1] <= data_in[63:32];
            write_regs[0] <= data_in[31:0];
        end else begin
            write_regs[6] <= write_regs[7];
            write_regs[5] <= write_regs[6];
            write_regs[4] <= write_regs[5];
            write_regs[3] <= write_regs[4];
            write_regs[2] <= write_regs[3];
            write_regs[1] <= write_regs[2];
            write_regs[0] <= write_regs[1];
            data_out <= write_regs[0];
            counter <= counter + 1;
            if(counter > 7) begin
                counter <= 0;
                resp <= 1'b1;
            end
        end
    end
end
    
    
endmodule
