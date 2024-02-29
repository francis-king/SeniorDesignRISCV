
`timescale 1ns / 1ps
module memoryFile (
    input MEM_V,
    input CLK,
    input reset,
    input v_we,
    input [63:0] mem_data,
    input [63:0] adddress,
    output wire mem_stall,
    output wire [63:0] data_out
);
// reg [63:12] cacheAddress;
`define memSize 15
`define fileName "TestInstructionMemLoad.mem"
//Page Size of 2^12 byte sized elements
reg [7:0] memory [`memSize:0];
`define numInstructions 4*1
// if (PC[63:12] == cacheAddress){
//     icache_r = 1;
// } else{
//     icache_r = 0;
// }
integer i;

always @(posedge CLK) begin
    if (reset) begin
        memory[0] <= 8'h01;
        memory[1] <= 8'h02;
        memory[2] <= 8'h03;
        memory[3] <= 8'h04;

        for(i = `numInstructions; i < `memSize + 1; i = i + 1) begin
            memory[i] = 'd0;
        end
        // $readmemh(`fileName, memory, 0, `numInstructions - 1);
    end else begin
        if (v_we) begin
            memory[{adddress[3:2], 2'b11}] <=
        end
    end
end
// assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;
assign mem_stall = 1'b0;
assign data = {memory[{adddress[3:2],2'b11}], memory[{adddress[3:2],2'b10}], memory[{PC[3:2],2'b01}], memory[{PC[3:2],2'b00}]};

//add in code to talk to memory bus


endmodule