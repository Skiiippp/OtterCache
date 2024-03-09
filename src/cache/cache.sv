//CPE333 lab2 Cache. James Gruber, Braydon Burkhardt rev A

module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    mem_itf.device cpu_itf,
    mem_itf.controller ca_itf

);

//logic clk, rst, cpu_read, cpu_write, lru_out, ca_resp, hit;
//logic [1:0] is_dirty, is_valid;
//logic cpu_mem_valid, load_data_a, load_data_b, lru_load, load_tag_a, load_tag_b, mem_read, mem_write, data_in_select, error;
//logic [1:0] set_dirty, write_dirty, set_valid, write_valid;

//assign ca_itf.clk = cpu_itf.clk;
//assign ca_itf.rst = cpu_itf.rst;
//assign ca_itf.mem_byte_enable = 4'b1111;
//assign ca_itf.mem_address = cpu_itf.mem_address;

//cache_control control(
//    .clk(clk),
//    .rst(rst),
//    .cpu_read(cpu_itf.mem_read),
//    .cpu_write(cpu_itf.mem_write),
//    .lru_out(lru_out),
//    .ca_resp(ca_itf.mem_resp),
//    .hit(hit),
//    .is_dirty(is_dirty),
//    .is_valid(is_valid),
//    .load_data_bytes_a(load_data_bytes_a),
//    .load_data_bytes_b(load_data_bytes_b),
//    .load_data_lines_a(load_data_lines_a),
//    .load_data_lines_b(load_data_lines_b),
//    .cpu_mem_valid(cpu_itf.mem_resp),
//    .load_data_a(load_data_a),
//    .load_data_b(load_data_b),
//    .lru_load(lru_load),
//    .load_tag_a(load_tag_a),
//    .load_tag_b(load_tag_b),
//    .mem_read(ca_itf.mem_read),
//    .mem_write(ca_itf.mem_write),
//    .data_in_select(data_in_select),
//    .error(error),
//    .set_dirty(set_dirty),
//    .write_dirty(write_dirty),
//    .set_valid(set_valid),
//    .write_valid(write_valid)
//);

//cache_datapath #(.s_offset(s_offset), .s_index(s_index)) datapath(
//    .clk(clk),
//    .rst(rst),
//    .cpu_memAddr(cpu_itf.mem_address),
//    .cpu_byteEn(cpu_itf.mem_byte_enable),
//    .cpu_dataIn(cpu_itf.mem_wdata),
//    .cpu_dataOut(cpu_itf.mem_rdata),
//    .ca_dataIn(ca_itf.mem_wdata),
//    .ca_dataOut(ca_itf.mem_rdata),
//    .load_dataBytes_A(load_data_bytes_a),
//    .load_dataBytes_B(load_data_bytes_b),
//    .load_dataLine_A(load_data_lines_a),
//    .load_dataLine_B(load_data_lines_b),
//    .load_tag_A(load_tag_a),
//    .load_tag_B(load_tag_b),
//    .dataInSelect(data_in_select),
//    .setValid(set_valid),
//    .writeValid(write_valid),
//    .setDirty(set_dirty),
//    .writeDirty(write_dirty),
//    .isHit(hit),
//    .isValid(is_valid),
//    .isDirty(is_dirty),
//    .LRULoad(lru_load),
//    .LRUOut(lru_out)
//    );

endmodule : cache
