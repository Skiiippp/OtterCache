//Cache datapath for array storage & supporting logic. Braydon Burkhardt 2.27.24 rev A

module cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input logic clk,
    input logic rst,
    
    input logic [31:0] memAddr,
    input logic [255:0] dataIn,
    input logic [31:0] dataOut,
    
    input logic [1:0] dataWriteEn, //data write enable for each way
    input logic [1:0] tagWriteEn, //tag write enable for each way
    input logic [1:0] setValid, //valid bit 1/0 to write each array to
    input logic [1:0] writeValid, //valid bit write enable for each array
    input logic [1:0] setDirty,
    input logic [1:0] writeDirty,
    
    output logic isHit, //1==hit, 0==miss
    output logic [1:0] isValid, //1==valid, 0==nonvalid
    output logic [1:0] isDirty, //1==dirty, 0==clean
    
    output logic LRUout //gets the bit of the LRU array at the index; 0=LRU way A, 0=LRU way B
);

//todo: add needed reset logic

//split the incoming mem address into its respective parts
logic [23:0] memTag = memAddr[31:8];
logic [2:0] memIndex = memAddr[7:5];
logic [4:0] memOffset = memAddr[4:0];

logic [2:0] rindex; //read index
logic [2:0] windex; //write index

//Data array stuff
logic dataread;
logic write_en_A [31:0]; //32 bytes long and we want to be able to be byte addressable to the CPU
logic write_en_B [31:0];
logic [255:0] datain;
logic [255:0] dataout_A;
logic [255:0] dataout_B;

data_array #(.s_offset(5), .s_index(3)) DataArrayA (
    .clk(clk),
    .rst(rst),
    .read(dataread),
    .write_en(write_en_A),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout_A)
  );
data_array #(.s_offset(5), .s_index(3)) DataArrayB (
    .clk(clk),
    .rst(rst),
    .read(dataread),
    .write_en(write_en_B),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout_B)
  );

//tag array stuff
logic tagread;
logic tagload_A, tagload_B;


array #(.s_index(3), .s_width(24)) TagArray_A (
    .clk(clk),
    .rst(rst),
    .read(tagread),
    .load(tagload_A),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  ); 
array #(.s_index(3), .s_width(24)) TagArray_B (
    .clk(clk),
    .rst(rst),
    .read(tagread),
    .load(tagload_B),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  ); 
  
array #(.s_index(3), .s_width(1)) validArray_A (
    .clk(clk),
    .rst(rst),
    .read(read),
    .load(load),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  ); 
array #(.s_index(3), .s_width(1)) validArray_B (
    .clk(clk),
    .rst(rst),
    .read(read),
    .load(load),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  ); 
  
array #(.s_index(3), .s_width(1)) dirtyArray_A (
    .clk(clk),
    .rst(rst),
    .read(read),
    .load(load),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  ); 
array #(.s_index(3), .s_width(1)) dirtyArray_B (
    .clk(clk),
    .rst(rst),
    .read(read),
    .load(load),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  );
  
array #(.s_index(3), .s_width(1)) LRUArray (
    .clk(clk),
    .rst(rst),
    .read(read),
    .load(load),
    .rindex(rindex),
    .windex(windex),
    .datain(datain),
    .dataout(dataout)
  );

endmodule : cache_datapath
