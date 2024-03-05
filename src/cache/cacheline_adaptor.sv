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
    
    input logic clk,
    input logic [255:0] par_d_in,
    input logic [31:0] ser_d_in,
    input logic write_enable,
    input logic read_enable,
    output logic resp,
    output logic [31:0] ser_d_out,
    output logic [255:0] par_d_out,

    // Just for passthrough to main mem
    mem_itf.device ca_itf,
    mem_itf.controller pmem_itf
    
    );
    
    // Probobly some hacky bullshit
    always_comb begin 
        pmem_itf.rst = ca_itf.rst;
        pmem_itf.mem_read = ca_itf.mem_read;
        pmem_itf.mem_write = ca_itf.mem_write;
        pmem_itf.mem_address = ca_itf.mem_address;
        pmem_itf.mem_wdata = ca_itf.mem_wdata;
        pmem_itf.mem_byte_enable = ca_itf.mem_byte_enable;
        ca_itf.mem_resp = pmem_itf.mem_resp;
        ca_itf.mem_rdata = pmem_itf.mem_rdata;

    end
    
    /*
    logic clk, write_enable, read_enable;
    logic [255:0] par_d_in, par_d_out;
    logic [31:0] ser_d_in, ser_d_out;
    
    always_comb begin
        clk = ca_itf.clk;
        write_enable = ca_itf.mem_write;
        read_enable = ca_itf.mem_read;
        par_d_in = ca_itf.mem_wdata;
        par_d_out = ca_itf.mem_rdata;
        ser_d_in = pmem_itf.mem_rdata;
        ser_d_out = pmem_itf.mem_wdata;
    end
    */
    
    serializer ser(clk, par_d_in, write_enable, read_enable, ser_d_out);
    deserializer des(clk, ser_d_in, write_enable, read_enable, par_d_out);
    
endmodule
