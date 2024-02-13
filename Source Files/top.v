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
wire [63:0] de_npc;
wire [31:0] de_ir;
wire        de_v;


//wires from EXECUTE stage
wire [63:0] exe_ir;
wire [4:0]  exe_drid; 

//wires from MEMORY stage
wire [63:0] mem_ir;
wire [4:0]  mem_drid;
wire [63:0] mem_alu_result;
wire        mem_stall;

//wires from WRITEBACK stage
wire [31:0] wb_ir;
wire [63:0] wb_csrfd;
wire [63:0] wb_data;
wire [63:0] wb_alu_result;
wire [63:0] wb_mem_result;
wire        wb_cs;
wire [63:0] wb_cause;
wire [63:0] wb_st_reg;
wire [63:0] wb_st_csr;
wire [1:0]  wb_pc_mux_out;
wire [63:0] wb_br_jmp_target;
 

//External wires


fetch fetch_stage(
    .WB_PC_MUX(wb_pc_mux),
    .WB_BR_JMP_PC(wb_br_jmp_pc),
    .DE_MTVEC(de_mtvec),
    .DE_CS(de_cs),
    .v_de_br_stall(),      //TODO: figure out stall
    .v_agex_br_stall(),
    .v_mem_br_stall(),
    .CLK(CLK),
    .RESET(RESET),
    .DE_NPC(de_npc),
    .DE_IR(de_ir),
    .DE_V(de_v),
    .F_IAM(f_iam),
    .F_IAF(f_iaf),
    .F_II(f_ii)
);

decode decode_stage(
    .DE_NPC(de_npc),
    .DE_IR(de_ir),
    .DE_V(de_v),
    WB_IR(wb_ir),
    WB_CSRFD(wb_csrfd),
    WB_DATA(wb_data),
    MEM_ALU_RESULT(mem_alu_result),
    WB_ALU_RESULT(wb_alu_result),
    WB_MEM_RESULT(wb_mem_result),
    WB_CS(wb_cs),
    WB_CAUSE(wb_cause),
    EXE_IR(exe_ir),
    MEM_IR(mem_ir),
    EXE_DRID(exe_drid),
    MEM_DRID(mem_drid),
    WB_ST_REG(wb_st_reg),
    WB_ST_CSR(wb_st_csr),
    WB_IR(wb_ir),
    MEM_STALL(mem_stall),
    CLK(CLK),
    reset(RESET),
    EXE_NPC,
    EXE_CSFR
    EXE_ALU_
    EXE_ALU_
    EXE_IR,
    EXE_V,
    EXE_ECAL
    RFD,
    v_de_br_stall
    DE_MTVEC
)







endmodule