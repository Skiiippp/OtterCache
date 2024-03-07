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
    
    //cpu io
    input logic [s_mask-1:0] cpu_memAddr,
    input logic [3:0] cpu_byteEn,
    input logic [s_mask-1:0] cpu_dataIn,
    output logic [s_mask-1:0] cpu_dataOut,
    
    //cacheline adapter io
    input logic [s_line-1:0] ca_dataIn,
    input logic [s_line-1:0] ca_dataOut,
    
    //fsm io
    input logic load_dataBytes_A, //either select bytes or the entire cacheline can be written to
    input logic load_dataBytes_B,
    input logic load_dataLine_A,
    input logic load_dataLine_B,
    input logic load_tag_A,
    input logic load_tag_B,
    input logic dataInSelect, //select CPU (0) or mem data (1) into data array
    input logic [1:0] setValid, //valid bit 1/0 to write each array to
    input logic [1:0] writeValid, //valid bit write enable for each array
    input logic [1:0] setDirty,
    input logic [1:0] writeDirty,
    
    output logic isHit, //1==hit, 0==miss
    output logic [1:0] isValid, //1==valid, 0==nonvalid
    output logic [1:0] isDirty, //1==dirty, 0==clean
    
    input logic LRULoad, //update LRU table, value is auto-generated in the datapath
    output logic LRUOut //gets the bit of the LRU array at the index; 0=LRU way A, 0=LRU way B
);

///////////////////////////// regs and wires /////////////////////////////////

//split the incoming mem address into its respective parts
logic [23:0] memTag;
logic [2:0] memIndex;
logic [4:0] memOffset;
always_comb begin
    memTag = cpu_memAddr[31:8];
    memIndex = cpu_memAddr[7:5];
    memOffset = cpu_memAddr[4:0];
end

//data array associated wires
logic [s_line-1:0] dataArrayOut_A;
logic [s_line-1:0] dataArrayOut_B;

//tag array associated wires
logic tagLoad_A, tagLoad_B;
logic [23:0] tagArrayOut_A, tageArrayOut_B;

//other metadata wires
logic validArrayOut_A, validArrayOut_B;
logic dirtyArrayOut_A, dirtyArrayOut_B;

///////////////////////////// comb/datapaths /////////////////////////////////

array #(.s_index(s_index), .width(24)) TagArray_A (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_tag_A),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(memTag),
    .dataout(tagArrayOut_A)
  ); 
array #(.s_index(s_index), .width(24)) TagArray_B (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_tag_A),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(memTag),
    .dataout(tagArrayOut_B)
  ); 
  
//seperate data reads allow to act as the 2:1 mux (hit controls read)
logic dataHit_A, dataHit_B;
always_comb begin
    dataHit_A = (tagArrayOut_A == memTag) ? 1'b1 : 1'b0;
    dataHit_B = (tagArrayOut_B == memTag) ? 1'b1 : 1'b0;
    assign isHit = (dataHit_A == 1'b1 || dataHit_B == 1'b1) ? 1'b1 : 1'b0;
end

//data input mux to data arrays
logic [s_line-1:0] dataArrayDataIn;
always_comb begin
    dataArrayDataIn = (dataInSelect == 1'b1) ? ca_dataOut : cpu_dataOut;
end

//data byte write logic. Shift 4 byte enable bits by 4*offset amount
logic [s_mask-1:0] dataWriteEn_A;
logic [s_mask-1:0] dataWriteEn_B;
always_comb begin
    logic [s_mask-1:0] dataWriteEn = cpu_byteEn << (4*memOffset);
    dataWriteEn_A = (load_dataLine_A == 1'b1) ? 32'hFFFFFFFF : ((load_dataBytes_A == 1'b1) ? dataWriteEn : 32'b0);
    dataWriteEn_B = (load_dataLine_B == 1'b1) ? 32'hFFFFFFFF : ((load_dataBytes_B == 1'b1) ? dataWriteEn : 32'b0);
end

data_array #(.s_offset(s_offset), .s_index(s_index)) DataArrayA (
    .clk(clk),
    .rst(rst),
    .read(dataHit_A),
    .write_en(dataWriteEn_A),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(dataArrayDataIn),
    .dataout(dataArrayOut_A)
  );
data_array #(.s_offset(s_offset), .s_index(s_index)) DataArrayB (
    .clk(clk),
    .rst(rst),
    .read(dataHit_B),
    .write_en(dataWriteEn_B),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(dataArrayDataIn),
    .dataout(dataArrayOut_B)
  );

//data output mux
logic [s_line-1:0] dataMuxInput;
logic [s_mask-1:0] preMaskedDataMux;
logic [s_mask-1:0] dataMuxOutput;
always_comb begin
    dataMuxInput = (dataHit_A == 1'b1) ? dataArrayOut_A : dataArrayOut_B;
    preMaskedDataMux = dataMuxInput >> (s_mask*memOffset); //shift by 32*offset, mask for the first 32 bits
    assign ca_dataIn = dataMuxInput;
    assign cpu_dataIn = preMaskedDataMux[s_mask-1:0];
end


array #(.s_index(s_index), .width(1)) validArray_A (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeValid[0]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setValid[0]),
    .dataout(isValid[0])
  ); 
array #(.s_index(s_index), .width(1)) validArray_B (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeValid[1]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setValid[1]),
    .dataout(isValid[1])
  ); 
  
array #(.s_index(s_index), .width(1)) dirtyArray_A (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeDirty[0]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setDirty[0]),
    .dataout(isDirty[0])
  ); 
array #(.s_index(s_index), .width(1)) dirtyArray_B (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(writeDirty[1]),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(setDirty[1]),
    .dataout(isDirty[1])
  );

//LRU: least recently used policy. Update based on hit so 0=wayA-LRU, 1=wayB-LRU
logic LRUDataIn;
always_comb begin
    if (dataHit_B == 1'b1) LRUDataIn = 1'b0; //if B is hit, A is the LRU
    else if (dataHit_A == 1'b1) LRUDataIn = 1'b1; //if A is hit, B is the LRU
end

array #(.s_index(s_index), .width(1)) LRUArray (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(LRULoad),
    .rindex(memIndex),
    .windex(memIndex),
    .datain(LRUDataIn),
    .dataout(LRUOut)
  );

endmodule : cache_datapath
