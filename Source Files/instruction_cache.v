module instruction_cache (
    input [63:0] PC,
    output icache_r,
    output [31:0] instruction
);

reg [63:12] cacheAddress;
`define memSize 4095
`define fileName "file.mem"
//Page Size of 2^12 byte sized elements
reg [7:0] memory [`numSize:0];
`define numInstructions 4*1
// if (PC[63:12] == cacheAddress){
//     icache_r = 1;
// } else{
//     icache_r = 0;
// }
integer i;
initial begin
    #readmemh(`fileName, memory, 0, `numInstructions - 1);
    for (i = i + 1; i < `numSize; i = i + 1) begin
        memory[i] = 'd0;
    end
end

assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;

assign instruction = {page[{PC[11:3],'b11}], page[{PC[11:3],'b10}], page[{PC[11:3],'b01}], page[{PC[11:3],'b00}]};
assign page = 0;
//add in code to talk to memory bus


endmodule