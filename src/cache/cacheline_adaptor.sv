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

    logic clk, 
        ser_write_enable, des_write_enable, 
        ser_read_enable, des_read_enable,
        ser_resp, des_resp;
    logic [255:0] par_d_in, par_d_out;
    logic [31:0] ser_d_in, ser_d_out;

    assign par_d_out = ca_itf.mem_rdata;
    assign ser_d_out = pmem_itf.mem_wdata;

    // read logic - deserialize
    always_comb begin
        ser_d_in = pmem_itf.mem_rdata;
        //par_d_out = ca_itf.mem_rdata;

        // passthrough read signal 
        if(ca_itf.mem_read) begin 
            pmem_itf.mem_read = 1'b1;
        end else begin
            pmem_itf.mem_read = 1'b0;
        end

        // wait for pmem resp, then write incoming data to deserializer
        if(pmem_itf.mem_resp) begin 
            des_write_enable = 1'b1;
        end else begin 
            des_write_enable = 1'b0;
        end

        // wait for des resp, then send response to cache
        if(des_resp) begin 
            ca_itf.mem_resp = 1'b1;
        end else begin 
            ca_itf.mem_resp = 1'b0;
        end
    end


    // write logic - serialize
    always_comb begin
        par_d_in = ca_itf.mem_wdata;
        //ser_d_out = pmem_itf.mem_wdata;

        // write signal - write to ca
        if(ca_itf.mem_write) begin 
            ser_write_enable = 1'b1;
        end else begin 
            ser_write_enable = 1'b0;
        end

        // wait for ser resp, then write to pmem
        if(ser_resp) begin 
            pmem_itf.mem_write = 1'b1;
        end else begin 
            pmem_itf.mem_write = 1'b0;
        end 
    end 

    // passthrough from cache to pmem
    always_comb begin 
        //pmem_itf.clk = ca_itf.clk;
        pmem_itf.rst = ca_itf.rst;
        pmem_itf.mem_address = ca_itf.mem_address;
        pmem_itf.mem_byte_enable = ca_itf.mem_byte_enable;
    end

    deserializer des(clk, ser_d_in, write_enable, read_enable, des_resp, par_d_out);
    serializer ser(clk, par_d_in, write_enable, read_enable, ser_resp, ser_d_out);

    /*
    always_comb begin
        // cache <-> ca
        clk = ca_itf.clk;
        write_enable = ca_itf.mem_write;
        read_enable = ca_itf.mem_read;
        par_d_in = ca_itf.mem_wdata;
        ca_itf.mem_rdata = par_d_out;
        ca_itf.mem_resp = ser_resp;

        // ca <-> pmem
        clk = pmem_itf.clk;
        ser_d_in = pmem_itf.mem_rdata;
        pmem_itf.mem_wdata = ser_d_out;


        //Passthrough - cache <-> pmem
        pmem_itf.rst = ca_itf.rst;
        pmem_itf.mem_address = ca_itf.mem_address;
        pmem_itf.mem_byte_enable = ca_itf.mem_byte_enable;
    end
    */

    /*
    serializer ser(clk, par_d_in, write_enable, read_enable, ser_d_out);
    deserializer des(clk, ser_d_in, write_enable, read_enable, par_d_out);
    */

endmodule
