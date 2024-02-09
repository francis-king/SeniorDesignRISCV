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


module csr_file(
    input [11:0] DR,
    input [11:0] SR,
    input [63:0] DATA,
    input [63:0] IR,
    input ST_REG,
    input CS,
    input [63:0] CAUSE,
    input [63:0] NPC,
    output reg [63:0] OUT,
    output reg [63:0] PC_OUT,
    input CLK,
    input RESET
);


reg [63:0] regFile [4095:0];
reg [1:0] PRIVILEGE;            //holds the privilige mode for the current thread
wire [1:0] RETURN_PRIVILEGE;
wire [31:0] RET;

assign RETURN_PRIVILEGE = regFile[{2'b0,PRIVILEGE[1:0],8'h00}][12:11];
assign RET = {2'b0,PRIVILEGE[3:2],28'h0200073};

always @(posedge CLK) begin
    if(RESET)begin
        PRIVILEGE <= 0;
        //TODO: reset misa and mhartid registers
    end
    else if(CS)begin

        regFile[{2'b0,NEW_PRIVILEGE,8'h42}] <= CAUSE;                                        //_Cause register set
        PC_OUT <= regFile[{2'b0,NEW_PRIVILEGE,8'h05}] + (4*(CAUSE[12:0]));                   //trap address in vector table
        regFile[{2'b0,2'b11,8'h00}][12:11] <= 2'b11;                                         //setting _status.xpp
        regFile[{2'b0,2'b11,8'h00}][2'b11+4] <= regFile[{2'b0,2'b11,8'h00}][PRIVILEGE[3:2]]; //setting _status.xpie to _status.yie
        regFile[{2'b0,2'b11,8'h00}][2'b11] <= 0;                                             //setting _status.xie to 0
        regFile[{2'b0,2'b11,8'h41}] <= NPC;                                                  //saving PC in _PC
        PRIVILEGE <= 2'b11;                                                                                                 

    end
    else if(IR == RET)begin
        regFile[{2'b0,PRIVILEGE[1:0],8'h00}][RETURN_PRIVILEGE[1:0]] <= regFile[{2'b0,PRIVILEGE[1:0],8'h00}][PRIVILEGE[1:0]+4];  //setting _status.yie to _status.xpie
        regFile[{2'b0,PRIVILEGE[1:0],8'h00}][PRIVILEGE[1:0]+4] <= 1;                                                            //setting _status.xie to 1
        PC_OUT <= regFile[{2'b0,PRIVILEGE[1:0],8'h41}];                                                                         //outputting _epc
        PRIVILEGE <= RETURN_PRIVILEGE;

    end
    else begin
        if (ST_REG)begin
            regFile[DR] <= DATA;
        end
        OUT <= regFile[SR];     

    end

end

endmodule