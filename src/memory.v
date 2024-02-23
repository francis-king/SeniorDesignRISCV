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
    input        RESET,
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
    input [31:0] MEM_IR,


    output reg [63:0] WB_NPC,
    output reg [31:0] WB_IR,
    output reg [63:0] WB_CSRFD,
    output reg [63:0] WB_ALU_RESULT,
    output reg [63:0] WB_MEM_RESULT,
    output reg        WB_PC_MUX,
    output reg        WB_V,
    output reg [63:0] WB_RFD,
    output reg [63:0] WB_DRID,
    output reg        WB_ECALL,
    output reg [31:0] MEM_IR_OLD,
    output reg        MEM_LAM,
    output reg        MEM_LAF,
    output reg        MEM_SAM,
    output reg        MEM_SAF,
    output reg        MEM_STALL
);


always @(*) begin
    if(MEM_IR[7:0] == 7'b1101111 || MEM_IR[7:0] == 7'b1100111)begin
        WB_PC_MUX = 1;
    end
    else if(MEM_IR[7:0] == 7'b1100011)begin
        case(MEM_IR[14:12])
            3'b000: begin
                WB_PC_MUX = (MEM_SR1 == MEM_SR2);         // beq
            end
            3'b001: WB_PC_MUX = (MEM_SR1 != MEM_SR2);         // bne
            3'b100: WB_PC_MUX = (MEM_SR1 < MEM_SR2);          // blt
            3'b101: WB_PC_MUX = (MEM_SR1 >= MEM_SR2);         // bge
            3'b110: WB_PC_MUX = (MEM_SR1 < MEM_SR2);          // bltu
            3'b111: WB_PC_MUX = (MEM_SR1 >= MEM_SR2);         // bgeu
        endcase
    end
    else begin
        WB_PC_MUX = 0;
    end
end

always @(posedge CLK) begin
    if(RESET) begin 
        MEM_STALL <= 1'b0;
    end
    else begin
        if (!WB_STALL) begin
            WB_NPC <= MEM_NPC;
            WB_ALU_RESULT <= WB_ALU_RESULT;
            WB_IR <= MEM_IR;
            WB_CSRFD <= MEM_CSRFD;
            WB_RFD <= MEM_RFD;
            WB_V <= MEM_V;
        end        
    end
end

endmodule



