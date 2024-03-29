`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2024 12:55:36 PM
// Design Name: 
// Module Name: writeback
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This File handles the writeback of data to the gpr and csr file.
//  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module writeback(
    input CLK,
    input RESET,
    input [63:0] WB_NPC,
    input [63:0] WB_MEM_RESULT,
    input [63:0] WB_ALU_RESULT,
    input [31:0] WB_IR_IN,
    input        WB_PC_MUX,
    input        WB_V,
    input [63:0] WB_CSRFD,
    input [63:0] WB_RFD,
    input        WB_ECALL,
    input        FE_IAM,
    input        FE_IAF,
    input        FE_II,
    input        MEM_LAM,
    input        MEM_LAF,
    input        MEM_SAM,
    input        MEM_SAF,
    input        TIMER,
    input        EXTERNAL,
    input [1:0] PRIVILEGE, //from decode

    output reg [63:0] WB_RF_DATA,
    output reg [63:0] WB_CSR_DATA,
    output reg [63:0] WB_BR_JMP_TARGET,
    output reg        WB_PC_MUX_OUT,
    output reg [31:0] WB_IR_OUT,
    output reg WB_ST_REG,
    output reg WB_ST_CSR,
    output reg [63:0] WB_CAUSE,
    output reg        WB_CS,
    output reg WB_STALL

    
);

wire wb_cs;
wire [63:0] wb_cause;

trap_handler Thandler(
    .CLK(CLK),
    .ECALL(WB_ECALL),
    .F_IAM(FE_IAM),
    .F_IAF(FE_IAF),
    .F_II(FE_II),
    .MEM_LAM(MEM_LAM),
    .MEM_LAF(MEM_LAF),
    .MEM_SAM(MEM_SAM),
    .MEM_SAF(MEM_SAF),
    .TIMER(TIMER),
    .EXTERNAL(EXTERNAL),
    .PRIVILEGE(PRIVILEGE),
    .CAUSE(wb_cause),
    .CS(wb_cs)
);


always @(posedge CLK) begin 
    if(RESET)begin
        WB_RF_DATA <= 0;
        WB_CSR_DATA <= 0;
        WB_BR_JMP_TARGET <= 0;
        WB_PC_MUX_OUT <= 0;
        WB_IR_OUT <= 0;
        WB_ST_REG <= 0;
        WB_ST_CSR <= 0;
        WB_CAUSE <= 0;
        WB_CS <= 0;
        WB_STALL <= 0; //Todo: implement missing WB_STALL logic
    end
    else begin
        if(WB_V) begin 
            WB_CAUSE <= wb_cause;
            WB_CS <= wb_cs;
            if(WB_IR_IN[6:0] == 7'b0000011)begin //Writeback result of load instruction (from memory) to register
                WB_RF_DATA <= WB_MEM_RESULT;
                WB_ST_REG <= 1;
                WB_ST_CSR <= 0;
            end
            else if(WB_IR_IN[6:0] == 7'b0010011 || WB_IR_IN[6:0] == 7'b0110011)begin  //Writeback ALU result to register
                WB_RF_DATA <= WB_ALU_RESULT;
                WB_ST_REG <= 1;
                WB_ST_CSR <= 0;
            end
            else if(WB_IR_IN[6:0] == 1110011)begin  //Writeback for CSR instruction
                WB_RF_DATA <= WB_RFD;
                WB_CSR_DATA <= WB_CSRFD;
                WB_ST_REG <= 1;
                WB_ST_CSR <= 1;
            end
            else if(WB_IR_IN[6:0] == 1100111 || WB_IR_IN[6:0] == 1101111)begin //Writeback NPC to general-purpose register
                WB_RF_DATA <= WB_NPC;
                WB_ST_REG <= 1;
                WB_ST_CSR <= 0;
            end
            else begin //otherwise, do not load into CSR/Reg
                WB_ST_REG <= 0;
                WB_ST_CSR <= 0;
            end
            
            WB_BR_JMP_TARGET <= WB_ALU_RESULT;
            WB_PC_MUX_OUT <= WB_PC_MUX;
            WB_IR_OUT <= WB_IR_IN;
        end 
        else begin 
            WB_ST_REG <= 1'b0;
            WB_ST_CSR <= 1'b0;
        end

    end
end


endmodule