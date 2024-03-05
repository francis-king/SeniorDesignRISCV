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
    output reg        WB_ECALL,
    output reg [31:0] MEM_IR_OLD,
    output reg        MEM_LAM,
    output reg        MEM_LAF,
    output reg        MEM_SAM,
    output reg        MEM_SAF,
    output            V_MEM_BR_STALL,
    output            V_MEM_TRAP_STALL,
    output            V_MEM_STALL
);

wire [63:0] data_out, data;
wire [1:0] size;
`define mem_opcode MEM_IR[6:0]

assign we = (MEM_IR[6:0] == 7'b0100011);
assign lam_in = (!we && (MEM_ALU_RESULT & 64'd7)) == 0 ? 1'b0 : 1'b1;
assign sam_in = (we && (MEM_ALU_RESULT & 64'd7)) == 0 ? 1'b0 : 1'b1;
assign size = (MEM_IR[14:12] == 3'b000) ? 2'b00 : (MEM_IR[14:12] == 3'b001) ? 2'b01 : (MEM_IR[14:12] == 3'b010) ? 2'b10 : 2'b11;
memoryFile m0 (.MEM_V(MEM_V), .CLK(CLK), .reset(RESET), .we(we), .size(size), .mem_data(MEM_SR2), .address(MEM_ALU_RESULT), .v_mem_stall(V_MEM_STALL), .data_out(data));


assign data_out = (MEM_IR[14:12] == 3'b000) ? (data&(64'h0FF)) : (MEM_IR[14:12] == 3'b001) ? (data&(64'h0FFFF)) : (MEM_IR[14:12] == 3'b010) ? (data&(64'h0FFFFFFFF)) : (MEM_IR[14:12] == 3'b011) ? data : (MEM_IR[14:12] == 3'b100) ? ((data&(64'h0FF))<<8) : (MEM_IR[14:12] == 3'b101) ? ((data&(64'h0FFFF))<<16) : ((data&(64'h0FFFFFFFF))<<32);
assign V_MEM_BR_STALL = (`mem_opcode == 7'b1100011 || `mem_opcode == 7'b1101111 || `mem_opcode == 7'b1100111) ? 1'd1 : 1'd0;
assign V_MEM_TRAP_STALL = (MEM_IR[27:0] == 28'h0000073) ? 1'd1 : 1'd0;

always @(posedge CLK) begin
    if(RESET) begin 
        WB_V <= 1'b0;
        MEM_LAF <= 1'b0;
        MEM_SAF <= 1'b0;
        WB_PC_MUX <= 1'b0;
        MEM_IR_OLD <= 0;
        WB_ALU_RESULT <= 0;
        WB_MEM_RESULT <= 0;
        WB_NPC <= 0;
        WB_IR <= 0;
        WB_CSRFD <= 0;
        WB_RFD <= 0;
        WB_ECALL <= 0;
        MEM_LAM <= 0;
        MEM_SAM <= 0;
    end
    else begin
        if (!WB_STALL) begin
            MEM_LAM <= lam_in;
            MEM_SAM <= sam_in;
            WB_NPC <= MEM_NPC;
            MEM_IR_OLD <= MEM_IR;
            WB_ALU_RESULT <= MEM_ALU_RESULT;
            WB_MEM_RESULT <= data_out;
            WB_IR <= MEM_IR;
            WB_CSRFD <= MEM_CSRFD;
            WB_RFD <= MEM_RFD;
            WB_V <= MEM_V;
            WB_ECALL <= MEM_ECALL;
            if(MEM_IR[7:0] == 7'b1101111 || MEM_IR[7:0] == 7'b1100111)begin
                WB_PC_MUX <= 1;
            end
            else if(MEM_IR[7:0] == 7'b1100011)begin
                case(MEM_IR[14:12])
                    3'b000: WB_PC_MUX <= (MEM_SR1 == MEM_SR2);         // beq
                    3'b001: WB_PC_MUX <= (MEM_SR1 != MEM_SR2);         // bne
                    3'b100: WB_PC_MUX <= (MEM_SR1 < MEM_SR2);          // blt
                    3'b101: WB_PC_MUX <= (MEM_SR1 >= MEM_SR2);         // bge
                    3'b110: WB_PC_MUX <= (MEM_SR1 < MEM_SR2);          // bltu
                    3'b111:  WB_PC_MUX <= (MEM_SR1 >= MEM_SR2);         // bgeu
                endcase
            end
            else begin
                WB_PC_MUX <= 0;
            end
        end        
    end
end

endmodule



