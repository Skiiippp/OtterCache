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
    
    input logic [s_mask:0] memAddr,
    input logic [s_line:0] dataIn,
    output logic [s_mask:0] dataOut,
    
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

///////////////////////////// regs and wires /////////////////////////////////

//split the incoming mem address into its respective parts
logic [23:0] memTag = memAddr[31:8];
logic [2:0] memIndex = memAddr[7:5];
logic [4:0] memOffset = memAddr[4:0];

//data array associated wires
logic writeEnDataArray_A [s_mask:0]; //want to be able to be byte writable from the CPU, handled in data_array
logic writeEnDataArray_A [s_mask:0];
logic [s_line:0] dataArrayOut_A;
logic [s_line:0] dataArrayOut_B;

//tag array associated wires
logic tagLoad_A, tagLoad_B;
logic [23:0] tagArrayOut_A, tageArrayOut_B;

//other metadata wires
logic validArrayOut_A, validArrayOut_B;
logic dirtyArrayOut_A, dirtyArrayOut_B;

array #(.s_index(s_index), .s_width(24)) TagArray_A (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(tagLoad_A),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(memTag),
    .dataout(tagArrayOut_A)
  ); 
array #(.s_index(s_index), .s_width(24)) TagArray_B (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(tagLoad_B),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(memTag),
    .dataout(tagArrayOut_B)
  ); 
  
//seperate data reads allow to act as the 2:1 mux (hit controls read)
always_comb begin
    logic dataRead_A = (tagArrayOut_A == memTag) ? 1'b1 : 1'b0;
    logic dataRead_B = (tagArrayOut_B == memTag) ? 1'b1 : 1'b0;
end

//todo: add/fix write code

data_array #(.s_offset(s_offset), .s_index(s_index)) DataArrayA (
    .clk(clk),
    .rst(rst),
    .read(dataRead),
    .write_en(writeEn_A),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(dataIn),
    .dataout(dataArrayOut_A)
  );
data_array #(.s_offset(s_offset), .s_index(s_index)) DataArrayB (
    .clk(clk),
    .rst(rst),
    .read(dataRead),
    .write_en(writeEn_B),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(dataIn),
    .dataout(dataArrayOut_B)
  );

//mux dataArrayOut values to output 32b
always_comb begin
    logic [s_line:0] dataMuxInput = (dataRead_A == 1'b1) ? dataArrayOut_A : dataArrayOut_B;
    logic [s_mask:0] dataMuxOutput = dataMuxInput[0:0];
    assign dataOut = dataMuxOutput;
end

array #(.s_index(s_index), .s_width(1)) validArray_A (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeValid[0]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setValid[0]),
    .dataout(isValid[0])
  ); 
array #(.s_index(s_index), .s_width(1)) validArray_B (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeValid[1]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setValid[1]),
    .dataout(isValid[1])
  ); 
  
array #(.s_index(s_index), .s_width(1)) dirtyArray_A (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeDirty[0]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setDirty[0]),
    .dataout(isDirty[0])
  ); 
array #(.s_index(s_index), .s_width(1)) dirtyArray_B (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeDirty[1]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setDirty[1]),
    .dataout(isDirty[1])
  );


logic LRU_load, LRU_datain;

//LRU code here

array #(.s_index(s_index), .s_width(1)) LRUArray (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(LRU_load),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(LRU_datain),
    .dataout(LRUout)
  );

endmodule : cache_datapath
