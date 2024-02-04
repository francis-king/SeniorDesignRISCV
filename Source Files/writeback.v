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

module writeback(
    input CLK,
    input [63:0] WB_NPC,
    input [63:0] WB_MEM_RESULT,
    input [63:0] WB_ALU_RESULT,
    input [63:0] WB_IR,
    input        WB_PC_MUX,
    input        WB_V,
    input [63:0] WB_CSRFD,
    input [63:0] WB_RFD,
    input [4:0]  WB_DRID,
    input        WB_ECALL,
    input        F_IAM,
    input        F_IAF,
    input        F_II,
    input        MEM_LAM,
    input        MEM_LAF,
    input        MEM_SAM,
    input        MEM_SAF,
    input        TIMER,
    input        EXTERNAL,
    input        PRIVILEGE, //from decode

    output [63:0] WB_RF_DATA,
    output [63:0] WB_CSR_DATA,
    output [63:0] WB_BR_JMP_TARGET,
    output [4:0]  WB_DRID_OUT,
    output        PC_MUX,
    output [63:0] WB_IR_OUT,

    output [63:0] CAUSE,
    output        CS, 

    
)

trap_handler T0(
    .CLK(CLK),
    .ECALL(WB_ECALL),
    .F_IAM(F_IAM),
    .F_IAF(F_IAF),
    .F_II(F_II),
    .MEM_LAM(MEM_LAM),
    .MEM_LAF(MEM_LAF),
    .MEM_SAM(MEM_SAM),
    .MEM_SAF(MEM_SAF),
    .TIMER(TIMER),
    .EXTERNAL(EXTERNAL),
    .PRIVILEGE(PRIVILEGE),
    .CAUSE(CAUSE),
    .CS(CS),
)


//mux for selecting data to be written to register file
always @(posedge CLK)begin
    if(WB_V)begin
        if(IR[6:0] == 7'b0000011)begin
            WB_RF_DATA <= WB_MEM_RESULT;
        end
        else if(IR[6:0] == 7'b0d10011)begin
            WB_RF_DATA <= WB_ALU_RESULT;
        end
        else if(IR[6:0] == 1110011)begin
            WB_RF_DATA <= WB_RFD;
        end
        else if(IR[6:0] == 1100111 || IR[6:0] == 1101111)begin
            WB_RF_DATA <= WB_NPC;
        end
        WB_CSR_DATA <= WB_CSRFD;
        WB_BR_JMP_TARGET <= WB_ALU_RESULT;
        PC_MUX <= WB_PC_MUX;
        WB_IR_OUT <= WB_IR;
    end

end






endmodule