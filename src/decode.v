`timescale 1ns / 1ps

module decode (   
    input        CLK,
    input        RESET,
    input [63:0] DE_NPC,
    input [31:0] DE_IR,
    input DE_V,
    input [31:0] WB_IR,
    input [63:0] WB_CSRFD,
    input [63:0] WB_RFD,
    input [63:0] MEM_ALU_RESULT,
    input [63:0] WB_ALU_RESULT,
    input [63:0] WB_MEM_RESULT,
    input        WB_CS,
    input [63:0] WB_CAUSE,
    input [31:0] EXE_IR_OLD,
    input [31:0] MEM_IR_OLD,
    input WB_ST_REG,
    input WB_ST_CSR,
    input V_MEM_STALL,
    
    output reg [63:0] EXE_NPC,
    output reg [63:0] EXE_CSRFD,
    output reg [63:0] EXE_ALU_ONE,
    output reg [63:0] EXE_ALU_TWO,
    output reg [31:0] EXE_IR,
    output reg        EXE_V,
    output reg        EXE_ECALL,
    output reg [63:0] EXE_RFD,
    output            v_de_br_stall,
    output     [63:0] DE_MTVEC,
    output DE_CS,
    output [1:0] privilige
);
`define de_func3 DE_IR[14:12]
`define de_opcode DE_IR[6:0]
wire DE_MEM_ALU_SR, DE_WB_ALU_SR, DE_WB_MEM_SR, LD_AGEX;
reg [63:0]  de_ALU1_out, de_ALU2_reg_out, exe_alu_in, de_ALU2_imm_out;
wire [63:0] de_reg_out_one, de_reg_out_two, exe_rfd_latch;
register_file regFile (
    .DR(WB_IR[11:7]), 
    .SR1(DE_IR[19:15]), 
    .SR2(DE_IR[24:20]), 
    .WB_DATA(WB_RFD), 
    .ST_REG(WB_ST_REG), 
    .reset(RESET),
    .out_one(de_reg_out_one), 
    .out_two(de_reg_out_two), 
    .CLK(CLK)
    );
assign v_ir = DE_V & DE_IR;
csr_file csr(
    .RESET(RESET),
    .DR(WB_IR[31:20]),
    .SR(DE_IR[31:20]),
    .IR(DE_IR[31:0]),
    .DATA(WB_CSRFD),
    .ST_REG(WB_ST_CSR),
    .CS(WB_CS),
    .CAUSE(WB_CAUSE),
    .NPC(DE_NPC),
    .OUT(exe_rfd_latch),
    .PC_OUT(DE_MTVEC),
    .CLK(CLK),
    .DE_CS(DE_CS),
    .privilige(privilige)
    );

//DE_ALU1_MUX
always @(*) begin
    if ((DE_IR[14] == 1) && (DE_IR[6:0] == 7'b1110011)) begin
        de_ALU1_out = de_reg_out_one;
    end else if (DE_MEM_ALU_SR == 1) begin
        de_ALU1_out = MEM_ALU_RESULT;
    end else if (DE_WB_ALU_SR == 1) begin
        de_ALU1_out = WB_ALU_RESULT;
    end else if (DE_WB_MEM_SR == 1) begin
        de_ALU1_out = WB_MEM_RESULT;
    end else begin
        de_ALU1_out = de_reg_out_one;
    end
end

//DE_ALU2_REG_MUX
always @(*) begin
    if (DE_MEM_ALU_SR == 1) begin
        de_ALU2_reg_out = MEM_ALU_RESULT;
    end else if (DE_WB_ALU_SR == 1) begin
        de_ALU2_reg_out = WB_ALU_RESULT;
    end else if (DE_WB_MEM_SR == 1) begin
        de_ALU2_reg_out = WB_MEM_RESULT;
    end else begin
        de_ALU2_reg_out = de_reg_out_two;
    end
end

assign DE_MEM_ALU_SR = ((EXE_IR_OLD[11:7] == DE_IR[19:15]) && !EXE_IR_OLD[6] && EXE_IR_OLD[4]) ? 'd1 : 'd0;
assign DE_WB_MEM_SR = ((MEM_IR_OLD[11:7] == DE_IR[19:15]) && !MEM_IR_OLD[6] && !MEM_IR_OLD[4]) ? 'd1 : 'd0;
assign DE_WB_ALU_SR = ((MEM_IR_OLD[11:7] == DE_IR[19:15]) && !MEM_IR_OLD[6] && MEM_IR_OLD[4]) ? 'd1 : 'd0;


always @(*) begin
    if (DE_IR[5] == 1) begin
        exe_alu_in = de_ALU2_reg_out;
    end else begin
        exe_alu_in = de_ALU2_imm_out;
    end
end

always @(*) begin
    //Store
    if (`de_opcode == 7'b0100011) begin
        de_ALU2_imm_out = (DE_IR[31]) ? {52'hFFFFFFFFFFFFF, DE_IR[31:25], DE_IR[11:7]} : {52'd0,DE_IR[31:25], DE_IR[11:7]};
    //Branch
    end else if (`de_opcode == 7'b1100011) begin
        de_ALU2_imm_out = (DE_IR[31]) ? {51'h7FFFFFFFFFFFF, DE_IR[31], DE_IR[7], DE_IR[30:25], DE_IR[11:8], 1'b0} : {51'd0, DE_IR[31], DE_IR[7], DE_IR[30:25], DE_IR[11:8], 1'b0};
    //LUI & AUIPC
    end else if (`de_opcode == 7'b0110111 || `de_opcode == 7'b0010111) begin
        de_ALU2_imm_out = (DE_IR[31]) ? {32'hFFFFFFFF, DE_IR[31:12], 12'd0} : {32'd0, DE_IR[31:12], 12'd0};
    //JALR or Load or Generic Immediate
    end else if (`de_opcode == 7'b1100111 || `de_opcode == 7'b0000011 || (`de_opcode == 7'b0010011 && DE_IR[13:12] != 2'b01) || (`de_opcode == 7'b0011011 && `de_func3 == 3'b000)) begin
        de_ALU2_imm_out = (DE_IR[31]) ? {52'hFFFFFFFFFFFFF, DE_IR[31:20]} : {52'd0,DE_IR[31:20]};
    end else if ((`de_opcode == 7'b0010011) && (DE_IR[13:12] == 2'b01)) begin
        de_ALU2_imm_out = {58'd0, DE_IR[25:20]};
    end else if (`de_opcode == 7'b0011011) begin
        de_ALU2_imm_out = {59'd0, DE_IR[24:20]};
    end
end

assign v_de_br_stall = (`de_opcode == 7'b1100011) ? 1'd1 : 1'd0;
assign EXE_ECALL_in = (DE_IR == 32'h00000073) ? 1'd1 : 1'd0;
assign LD_AGEX = DE_V && !V_MEM_STALL;
assign EXE_V_in = DE_V && !V_MEM_STALL;
always @(posedge CLK) begin
    if (RESET) begin
        EXE_NPC <= 'd0;
        EXE_CSRFD <= 'd0;
        EXE_IR <= 'd0;
        EXE_V <= 'd0;
        EXE_ECALL <= 'd0;
        EXE_RFD <= 'd0;
    end else if (LD_AGEX) begin
        EXE_RFD <= exe_rfd_latch;
        EXE_NPC <= DE_NPC; 
        EXE_CSRFD <= de_ALU1_out;
        EXE_ALU_ONE <= de_ALU1_out;
        EXE_ALU_TWO <= exe_alu_in;
        EXE_IR <= DE_IR;
        EXE_V <= EXE_V_in;
        EXE_ECALL <= EXE_ECALL_in;
    end
end
endmodule