`timescale 1ns / 1ps

//cache datapath testbench. Braydon Burkhardt rev A

module cache_datapath_testbench();
    timeunit 1ns;
    timeprecision 1ns;

    parameter s_offset = 5;
    parameter s_index  = 3;
    parameter s_tag    = 32 - s_offset - s_index;
    parameter s_mask   = 2**s_offset;
    parameter s_line   = 8*s_mask;
    parameter num_sets = 2**s_index;

    logic clk = 1; always #1 clk = ~clk;
    default clocking cb @(posedge clk); endclocking

    logic rst = 1'b0;
    
    //cpu io
    logic [s_mask-1:0] cpu_memAddr = 0;
    logic [3:0] cpu_byteEn = 0;
    logic [s_mask-1:0] cpu_dataIn;
    logic [s_mask-1:0] cpu_dataOut;
    
    //cacheline adapter io
    logic [s_line-1:0] ca_dataIn;
    logic [s_line-1:0] ca_dataOut;
    
    //fsm io
    logic load_dataBytes_A = 0;
    logic load_dataBytes_B = 0;
    logic load_dataLine_A = 0;
    logic load_dataLine_B = 0;
    logic load_tag_A = 0;
    logic load_tag_B = 0;
    logic dataInSelect = 0; //select CPU (0) or mem data (1) into data array
    logic [1:0] setValid = 0; //valid bit 1/0 to write each array to
    logic [1:0] writeValid = 0; //valid bit write enable for each array
    logic [1:0] setDirty = 0;
    logic [1:0] writeDirty = 0;
    
    logic isHit; //1==hit, 0==miss
    logic [1:0] isValid; //1==valid, 0==nonvalid
    logic [1:0] isDirty; //1==dirty, 0==clean
    
    logic LRULoad = 0; //update LRU table, value is auto-generated in the datapath
    logic LRUOut; //gets the bit of the LRU array at the index; 0=LRU way A, 0=LRU way B

    cache_datapath #(.s_offset(s_offset), .s_index(s_index)) datapath(
    .clk(clk),
    .rst(rst),
    .cpu_memAddr(cpu_memAddr),
    .cpu_byteEn(cpu_byteEn),
    .cpu_dataIn(cpu_dataIn),
    .cpu_dataOut(cpu_dataOut),
    .ca_dataIn(ca_dataIn),
    .ca_dataOut(ca_dataOut),
    .load_dataBytes_A(load_dataBytes_A),
    .load_dataBytes_B(load_dataBytes_B),
    .load_dataLine_A(load_dataLine_A),
    .load_dataLine_B(load_dataLine_B),
    .load_tag_A(load_tag_A),
    .load_tag_B(load_tag_B),
    .dataInSelect(dataInSelect),
    .setValid(setValid),
    .writeValid(writeValid),
    .setDirty(setDirty),
    .writeDirty(writeDirty),
    .isHit(isHit),
    .isValid(isValid),
    .isDirty(isDirty),
    .LRULoad(LRULoad),
    .LRUOut(LRUOut)
    );
    
initial begin
    $timeformat(-9, 3, "ns", 10);

    //initial reset
    rst = 1'b1;
    repeat (50) @(posedge clk);
    rst = 1'b0;

    //cacheline tag and data load test
    cpu_memAddr = 32'b01100000000000000000000001100000; //tag=12582912  index=3    offset=0
    ca_dataOut = 256'hdeadbeef;
    dataInSelect = 1'b1;
    ##5
    load_dataLine_A = 1'b1;
    load_tag_A = 1'b1;
    ##1
    load_dataLine_A = 1'b0;
    load_tag_A = 1'b0;
    

end
    
    
    
endmodule









