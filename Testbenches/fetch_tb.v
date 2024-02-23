module fetch_tb();

reg mem_stall, WB_PC_MUX, DE_CS, v_de_br_stall, v_agex_br_stall, v_mem_br_stall;
reg [63:0] WB_BR_JMP_PC, DE_MTVEC;
reg CLK, RESET;
wire [63:0] DE_NPC;
wire [31:0] DE_IR;
wire DE_V, FE_IAM, FE_IAF, FE_II;

fetch f0 (.mem_stall(mem_stall), .WB_PC_MUX(WB_PC_MUX), .WB_BR_JMP_PC(WB_BR_JMP_PC), .DE_MTVEC(DE_MTVEC), .DE_CS(DE_CS), .v_de_br_stall(v_de_br_stall), .v_agex_br_stall(v_agex_br_stall), .v_mem_br_stall(v_mem_br_stall), .CLK(CLK), .RESET(RESET), .DE_NPC(DE_NPC), .DE_IR(DE_IR), .DE_V(DE_V), .FE_IAM(F_IAM), .FE_IAF(F_IAF), .FE_II(F_II));

initial begin
    mem_stall <= 1'b0;
    WB_PC_MUX <= 1'b0;
    WB_BR_JMP_PC <= 64'h1234567123456789;
    DE_MTVEC <= 32'd0;
    DE_CS <= 1'b0;
    v_de_br_stall <= 1'b0;
    v_agex_br_stall <= 1'b0;
    v_mem_br_stall <= 1'b0;
    CLK <= 1'b0;
    RESET <= 1'b1;

    #20

    RESET <= 1'b0;
end

always begin
    #10 CLK <= !CLK;
end
endmodule