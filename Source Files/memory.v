`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2024 12:55:36 PM
// Design Name: 
// Module Name: csr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This File holds the Control Status Registers for the core and handles
// the hardware operations that occur when a context switch occurs (interrupt/exception).
// The CSR file can also be written to and read from using the 6 csr instructions
//  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory(
    input        CLK,
    input        WB_STALL,
    input [63:0] MEM_NPC,
    input [63:0] MEM_CSRFD,
    input [63:0] MEM_ALU_RESULT,
    input [63:0] MEM_SR1,
    input [63:0] MEM_SR2,
    input        MEM_V,
    input [63:0] MEM_RFD,
    input [63:0] MEM_DRID,
    input        MEM_ECALL,


    output [63:0] WB_NPC,
    output [63:0] WB_CSRFD,
    output [63:0] WB_ALU_RESULT,
    output [63:0] WB_MEM_RESULT,
    output [63:0] WB_PC_MUX,
    output        WB_V,
    output [63:0] WB_RFD,
    output [63:0] WB_DRID,
    output        WB_ECALL,
    

)


always @(posedge clk) begin
    if (!WB_stall) begin
        WB_PC <= EXE_PC;
        WB_ALU_RESULT <= WB_ALU_RESULT;
        WB_IR <= EXE_IR;
        WB_SR1 <= EXE_ALU1;
        WB_SR2 <= EXE_ALU2;
        WB_CSRFD <= EXE_CSRFD;
        WB_RFD <= EXE_RFD;
        WB_V <= EXE_V;
    end
end

endmodule