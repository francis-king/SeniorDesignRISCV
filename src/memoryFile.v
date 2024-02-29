
`timescale 1ns / 1ps
module memoryFile (
    input MEM_V,
    input CLK,
    input reset,
    input we,
    input [1:0] size,
    input [63:0] mem_data,
    input [63:0] address,
    output reg v_mem_stall,
    output [63:0] data_out
);
// reg [63:12] cacheAddress;
`define memSize 15
//Page Size of 2^12 byte sized elements
reg [7:0] memory [`memSize:0];
`define numInstructions 8*1

integer i;
always @(posedge CLK) begin
    if (reset) begin
        v_mem_stall <= 1'b0;
        memory[0] <= 8'h01;
        memory[1] <= 8'h02;
        memory[2] <= 8'h03;
        memory[3] <= 8'h04;
        memory[4] <= 8'h01;
        memory[5] <= 8'h02;
        memory[6] <= 8'h03;
        memory[7] <= 8'h04;

        for(i = `numInstructions; i < `memSize + 1; i = i + 1) begin
            memory[i] = 'd0;
        end
    end else begin
        if (we && MEM_V) begin
            if (size == 2'b00) begin
                memory[{address[3], 3'b000}] <= mem_data[7:0];
            end else if (size == 2'b01) begin
                memory[{address[3], 3'b001}] <= mem_data[15:8];
                memory[{address[3], 3'b000}] <= mem_data[7:0];
            end else if (size == 2'b10) begin
                memory[{address[3], 3'b011}] <= mem_data[31:24];
                memory[{address[3], 3'b010}] <= mem_data[23:16];
                memory[{address[3], 3'b001}] <= mem_data[15:8];
                memory[{address[3], 3'b000}] <= mem_data[7:0];
            end else if (size == 2'b11) begin
                memory[{address[3], 3'b111}] <= mem_data[63:56];
                memory[{address[3], 3'b110}] <= mem_data[55:48];
                memory[{address[3], 3'b101}] <= mem_data[47:40];
                memory[{address[3], 3'b100}] <= mem_data[39:32];
                memory[{address[3], 3'b011}] <= mem_data[31:24];
                memory[{address[3], 3'b010}] <= mem_data[23:16];
                memory[{address[3], 3'b001}] <= mem_data[15:8];
                memory[{address[3], 3'b000}] <= mem_data[7:0];
            end
        end
    end
end

assign data_out = {memory[{address[3],3'b111}], memory[{address[3],3'b110}], memory[{address[3],3'b101}], memory[{address[3],3'b100}], memory[{address[3],3'b011}], memory[{address[3],3'b010}], memory[{address[3],3'b001}], memory[{address[3],3'b000}]};

//add in code to talk to memory bus


endmodule