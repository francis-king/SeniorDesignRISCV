`timescale 1ns / 1ps
module memory(
    input        CLK,
    input        WB_STALL,
    input [63:0] MEM_NPC,
    input [63:0] MEM_CSRFD,
    input [63:0] MEM_ALU_RESULT,
    input [63:0] MEM_SR1,
    input [63:0] MEM_SR2,
    input        MEM_V,
    input [63:0] MEM_RFD,
    input [63:0] MEM_DRID,
    input        MEM_ECALL,

    output [63:0] WB_NPC,
    output [63:0] WB_CSRFD,
    output [63:0] WB_ALU_RESULT,
    output [63:0] WB_MEM_RESULT,
    output [63:0] WB_PC_MUX,
    output        WB_V,
    output [63:0] WB_RFD,
    output [63:0] WB_DRID,
    output        WB_ECALL,
    output        MEM_LAM,
    output        MEM_LAF,
    output        MEM_SAM,
    output        MEM_SAF,
    output reg [0:0] MEM_PC_MUX
);

reg branch_taken;

always @(*) begin
    case(MEM_NPC[6:0]) 
        // conditional
        7'b1100011: branch_taken = (MEM_SR1 == MEM_SR2);         // beq
        7'b1100111: branch_taken = (MEM_SR1 != MEM_SR2);         // bne
        7'b1100011: branch_taken = (MEM_SR1 < MEM_SR2);          // blt
        7'b1101011: branch_taken = (MEM_SR1 >= MEM_SR2);         // bge
        7'b1100011: branch_taken = (MEM_SR1 < MEM_SR2);          // bltu
        7'b1101011: branch_taken = (MEM_SR1 >= MEM_SR2);         // bgeu

        // uncoditional
        7'b1101111: branch_taken = 1;                        // jal
        7'b1100111: branch_taken = 1;                        // jalr
            
        default: branch_taken = 0; // default: no branch
    endcase
        
    MEM_PC_MUX = branch_taken ? 1'b1 : 1'b0; 
end

always @(posedge CLK) begin
    if (!WB_STALL) begin
        WB_NPC <= MEM_NPC;
        WB_CSRFD <= MEM_CSRFD;
        WB_ALU_RESULT <= MEM_ALU_RESULT;
        WB_MEM_RESULT <= 0; // Placeholder, you need to define it
        WB_PC_MUX <= MEM_PC_MUX;
        WB_V <= MEM_V;
        WB_RFD <= MEM_RFD;
        WB_DRID <= MEM_DRID;
        WB_ECALL <= MEM_ECALL;
    end
end
endmodule

