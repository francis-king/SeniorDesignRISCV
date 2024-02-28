`timescale 1ns / 1ps

module decode_tb();

reg clk, reset, de_v, wb_cs, wb_st_reg, wb_st_csr, mem_stall;
reg [4:0] exe_drid, mem_drid;
reg [31:0] de_ir, wb_ir;
reg [63:0] de_npc, wb_csrfd, wb_rfd, mem_alu_result, wb_alu_result, 
           wb_mem_result, wb_cause, exe_ir_old, mem_ir_old;
wire exe_v, exe_ecall, v_de_br_stall;
wire [31:0] exe_npc, exe_ir;
wire [63:0] exe_csrfd, exe_alu_one, exe_alu_two, exe_rfd, de_mtvec;

decode decode_stage(
    .DE_NPC(de_npc),
    .DE_IR(de_ir),
    .DE_V(de_v),
    .WB_IR(wb_ir),
    .WB_CSRFD(wb_csrfd),
    .WB_RFD(wb_rfd),
    .MEM_ALU_RESULT(mem_alu_result),
    .WB_ALU_RESULT(wb_alu_result),
    .WB_MEM_RESULT(wb_mem_result),
    .WB_CS(wb_cs),
    .WB_CAUSE(wb_cause),
    .EXE_IR_OLD(exe_ir_old),
    .MEM_IR_OLD(mem_ir_old),
    .WB_ST_REG(wb_st_reg),
    .WB_ST_CSR(wb_st_csr),
    .MEM_STALL(mem_stall),
    .CLK(clk),
    .RESET(reset),
    .EXE_NPC(exe_npc),
    .EXE_CSRFD(exe_csrfd),
    .EXE_ALU_ONE(exe_alu_one),
    .EXE_ALU_TWO(exe_alu_two),
    .EXE_IR(exe_ir),
    .EXE_V(exe_v),
    .EXE_ECALL(exe_ecall),
    .EXE_RFD(exe_rfd),
    .v_de_br_stall(v_de_br_stall),
    .DE_MTVEC(de_mtvec));
    
initial begin
    clk = 0;
    reset = 1;
    
    #20 
    reset = 0;
    de_npc = 4;
    de_ir = 32'h00508093;
    de_v = 1;
    wb_ir = 32'h0;
    wb_csrfd = 64'h0;
    wb_rfd = 64'h0;
    mem_alu_result = 64'h0;
    wb_alu_result = 64'h0;
    wb_mem_result = 64'h0;
    wb_cs = 0;
    wb_cause = 0;    
    exe_ir_old = 0;
    mem_ir_old = 0;
    wb_st_reg = 0;
    wb_st_csr = 0;
    mem_stall = 0;
    
    
end
    
    always #5 clk = ~clk;
    
endmodule
