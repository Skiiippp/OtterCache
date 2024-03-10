`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2024 10:58:47 AM
// Design Name: 
// Module Name: serdes
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


module cacheline_adaptor(
    
    mem_itf.device ca_itf,
    mem_itf.controller pmem_itf
    
    );

    logic ca_we_buffer;
    always_ff @ (posedge ca_itf.clk) begin 
        ca_we_buffer <= ca_itf.mem_wdata;
    end

    // passthrough
    assign pmem_itf.clk = ca_itf.clk;
    assign pmem_itf.mem_address = ca_itf.mem_address;
    assign pmem_itf.rst = ca_itf.rst;
    assign pmem_itf.mem_byte_enable = ca_itf.mem_byte_enable;
    assign pmem_itf.mem_read = ca_itf.mem_read;
    assign pmem_itf.mem_write = ca_itf.mem_write;
    assign ca_itf.mem_resp = pmem_itf.mem_resp;

    serializer ser(ca_itf.clk, ca_itf.mem_wdata, ca_itf.mem_write, ca_we_buffer, pmem_itf.mem_wdata);
    deserializer des(ca_itf.clk, pmem_itf.mem_rdata, pmem_itf.mem_resp, ca_itf.mem_read, ca_itf.mem_rdata);

endmodule
