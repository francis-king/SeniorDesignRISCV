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
//stall signals
wire v_de_br_stall;
wire mem_stall;
wire wb_stall;


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
wire [63:0] exe_ir_old;
wire [4:0]  exe_drid;
wire [31:0] exe_npc; 
wire [63:0] exe_csrfd; 
wire [63:0] exe_alu_one; 
wire [63:0] exe_alu_two; 
wire [63:0] exe_rfd; 
wire [31:0] exe_ir; 
wire        exe_valid; 
wire        exe_ecall; 

//wires from MEMORY stage
wire [63:0] mem_ir_old;
wire [4:0]  mem_drid;
wire [63:0] mem_alu_result;
wire        mem_stall;
wire [63:0] mem_pc;
wire [63:0] mem_alu_result;
wire [31:0] mem_ir;
wire [63:0] mem_sr2;
wire [63:0] mem_sr1;
wire        mem_v;
wire [63:0] mem_csrfd;
wire [63:0] mem_rfd;
wire        mem_ecall;

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
    .v_de_br_stall(v_de_br_stall),      //TODO: figure out stall
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
    .WB_IR(wb_ir),
    .WB_CSRFD(wb_csrfd),
    .WB_DATA(wb_data),
    .MEM_ALU_RESULT(mem_alu_result),
    .WB_ALU_RESULT(wb_alu_result),
    .WB_MEM_RESULT(wb_mem_result),
    .WB_CS(wb_cs),
    .WB_CAUSE(wb_cause),
    .EXE_IR_OLD(exe_ir_old),
    .MEM_IR_OLD(mem_ir_old),
    .EXE_DRID(exe_drid),
    .MEM_DRID(mem_drid),
    .WB_ST_REG(wb_st_reg),
    .WB_ST_CSR(wb_st_csr),
    .WB_IR(wb_ir),
    .MEM_STALL(mem_stall),
    .CLK(CLK),
    .reset(RESET),
    .EXE_NPC(exe_npc),
    .EXE_CSFR(exe_csrfd),
    .EXE_ALU_ONE(exe_alu_one),
    .EXE_ALU_TWO(exe_alu_two),
    .EXE_IR(exe_ir),
    .EXE_V(exe_v),
    .EXE_ECALL(exe_ecall),
    .EXE_RFD(exe_rfd),
    .v_de_br_stall(v_de_br_stall),
    .DE_MTVEC(de_mtvec)
);

execute execute_stage(
    .CLK(CLK),
    .EXE_NPC(exe_npc),
    .EXE_CSFR(exe_csrfd),
    .EXE_ALU_ONE(exe_alu_one),
    .EXE_ALU_TWO(exe_alu_two),
    .EXE_IR(exe_ir),
    .EXE_V(exe_v),
    .EXE_ECALL(exe_ecall),
    .EXE_RFD(exe_rfd),
    .MEM_PC(mem_pc),
    .MEM_ALU_RESULT(mem_alu_result),
    .MEM_IR(mem_ir),
    .MEM_SR2(mem_sr2),
    .MEM_SR1(mem_sr1),
    .MEM_V(mem_v),
    .MEM_CSRFD(mem_csrfd),
    .MEM_RFD(mem_rfd),
    .MEM_stall(mem_stall),
    .MEM_ECALL(mem_ecall)
);

memory memory_stage(
    .CLK(CLK),
    .WB_STALL(wb_stall),
    .MEM_NPC(mem_n),
    .MEM_CSRFD,
    .MEM_ALU_RESULT,
    .MEM_SR1,
    .MEM_SR2,
    .MEM_V,
    .MEM_RFD,
    .MEM_DRID,
    .MEM_ECALL,
    .WB_NPC,
    .WB_CSRFD,
    .WB_ALU_RESULT,
    .WB_MEM_RESULT,
    .WB_PC_MUX,
    .WB_V,
    .WB_RFD,
    .WB_DRID,
    .WB_ECALL,
    .MEM_LAM,
    .MEM_LAF,
    .MEM_SAM,
    .MEM_SAF,
);







endmodule