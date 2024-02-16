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

module trap_handler(
    input         CLK,
    input         ECALL,
    input         F_IAM,
    input         F_IAF,
    input         F_II,
    input         MEM_LAM,
    input         MEM_LAF,
    input         MEM_SAM,
    input         MEM_SAF,
    input         TIMER,
    input         EXTERNAL,
    input  [1:0]  PRIVILEGE,

    output [63:0] CAUSE,
    output        CS
    
);


always@(*)begin
    if(F_IAM)begin
        CS = 1;
        CAUSE = 0;
    end
    else if(F_IAF)begin
        CS = 1;
        CAUSE = 1;
    end
    else if(F_II)begin
        CS = 1;
        CAUSE = 2;
    end
    else if(MEM_LAM)begin
        CS = 1;
        CAUSE = 4;
    end
    else if(MEM_LAF)begin
        CS = 1;
        CAUSE = 5;
    end
    else if(MEM_SAM)begin
        CS = 1;
        CAUSE = 6;
    end
    else if(MEM_SAF)begin
        CS = 1;
        CAUSE = 7;
    end
    else if(ECALL)begin
        CS = 1;
        CAUSE = {1'b1,61'b0,PRIVILEGE};
    end
    else if(TIMER)begin
        CS = 1;
        CAUSE = {1'b1,60'b0,PRIVILEGE+4};
    end
    else if(EXTERNAL)begin
        CS = 1;
        CAUSE = {1'b1,59'b0,PRIVILEGE+8};
    end 
    else begin
        CS = 0;
    end
end

endmodule