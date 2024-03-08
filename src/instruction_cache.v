
`timescale 1ns / 1ps
module instruction_cache (
    input CLK,
    input reset,
    input [63:0] PC,
    output wire icache_r,
    output wire [31:0] instruction
);
// reg [63:12] cacheAddress;
//Page Size of 2^4 byte sized elements
//Memory Currently Loops. As a result, a fake halt instruction is needed.
`define fe_memSize 19
reg [7:0] memory [`fe_memSize:0];
//`define fe_numInstructions 4*5
//integer i;
localparam FILE_NAME = "../integer_alrithmetic.sim";
initial begin
    $readmemh (FILE_NAME, memory);
end
//always @(posedge CLK) begin
//    if (reset) begin
//        //ADDI R1, R1, #5
//        memory[0] <= 8'h93;
//        memory[1] <= 8'h80;
//        memory[2] <= 8'h50;
//        memory[3] <= 8'h00;
////        //ADDI R1, R1, #5
////        memory[4] <= 8'h93;
////        memory[5] <= 8'h80;
////        memory[6] <= 8'h50;
////        memory[7] <= 8'h00;
//        //SLTI R2, R1, #9
////        memory[4] <= 8'h13;
////        memory[5] <= 8'hA1;
////        memory[6] <= 8'h90;
////        memory[7] <= 8'h00;
//        //SLTI R2, R1, #9
//        memory[4] <= 8'h13;
//        memory[5] <= 8'hA1;
//        memory[6] <= 8'hF0;
//        memory[7] <= 8'hFF;
//        //SLTI R3, R3, #0
//        memory[8] <= 8'h93;
//        memory[9] <= 8'hB1;
//        memory[10] <= 8'hF1;
//        memory[11] <= 8'hFF;
//        //JAL R0, #-4
//        memory[12] <= 8'h6F;
//        memory[13] <= 8'hF0;
//        memory[14] <= 8'hDF;
//        memory[15] <= 8'hFF;

//        for(i = `fe_numInstructions; i < `fe_memSize + 1; i = i + 1) begin
//            memory[i] = 'd0;
//        end
//    end
//end
// assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;
assign icache_r = 1'b1;
assign instruction = {memory[{PC[63:2],2'b11}], memory[{PC[63:2],2'b10}], memory[{PC[63:2],2'b01}], memory[{PC[63:2],2'b00}]};

//add in code to talk to memory bus


endmodule