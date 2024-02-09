`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2024 12:55:36 PM
// Design Name: 
// Module Name: TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This file connects all the different pipeline stages.
//  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    input CLK,
    input RESET,

)

//wires from FETCH stage
wire f_iam;
wire f_iaf;
wire f_ii;

//wires from DECODE stage
wire [63:0] de_mtvec;
wire        de_cs;


//wires from EXECUTE stage

//wires from MEMORY stage
wire [1:0]  wb_pc_mux_out;
wire [63:0] wb_br_jmp_target;

//wires from WRITEBACK stage 

//External wires


fetch fetch_stage(
    .WB_PC_MUX(wb_pc_mux),
    .WB_BR_JMP_PC(wb_br_jmp_pc),
    .DE_MTVEC(de_mtvec),

);







endmodule