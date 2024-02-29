
`timescale 1ns / 1ps
module instruction_cache (
    input CLK,
    input reset,
    input [63:0] PC,
    output wire icache_r,
    output wire [31:0] instruction
);
// reg [63:12] cacheAddress;
`define memSize 15
`define fileName "TestInstructionMemLoad.mem"
//Page Size of 2^4 byte sized elements
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
        memory[0] <= 8'h93;
        memory[1] <= 8'h80;
        memory[2] <= 8'h50;
        memory[3] <= 8'h00;

        for(i = `numInstructions; i < `memSize + 1; i = i + 1) begin
            memory[i] = 'd0;
        end
        // $readmemh(`fileName, memory, 0, `numInstructions - 1);
    end
end
// assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;
assign icache_r = 1'b1;
assign instruction = {memory[{PC[3:2],2'b11}], memory[{PC[3:2],2'b10}], memory[{PC[3:2],2'b01}], memory[{PC[3:2],2'b00}]};

//add in code to talk to memory bus


endmodule