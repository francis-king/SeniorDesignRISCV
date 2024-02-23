`timescale 1ns / 1ps

module fetch (
    input mem_stall,
    input WB_PC_MUX,
    input [63:0] WB_BR_JMP_PC,
    input [63:0] DE_MTVEC,
    input DE_CS,
    input v_de_br_stall,
    input v_agex_br_stall,
    input v_mem_br_stall,
    input CLK,
    input RESET,
    output reg [63:0] DE_NPC,
    output reg [31:0] DE_IR,
    output reg DE_V,
    output FE_IAM,
    output FE_IAF,
    output FE_II
);

`define opcode DE_IR[6:0]
`define func3 DE_IR[14:12]
reg [63:0] FE_PC;
wire [31:0] FE_instruction;
wire FE_LD_PC, FE_LD_DE;
wire [63:0] FE_PC_input;
wire icache_r;
always @(posedge CLK) begin
    if (RESET) begin
        FE_PC <= 'd0; //TODO: change this to inital PC
    end else if (FE_LD_PC) begin
        FE_PC <= FE_PC_input;
    end
    if (FE_LD_DE) begin
        DE_V <= icache_r && !v_de_br_stall && !v_agex_br_stall && !v_mem_br_stall;
        DE_IR <= FE_instruction;
        DE_NPC <= FE_PC + 4;
    end
end


instruction_cache a0 (.PC(FE_PC), .icache_r(icache_r), .instruction(FE_instruction), .CLK(CLK), .reset(RESET));

assign FE_IAF = ~icache_r;
assign FE_II = ((`opcode == 7'b0110111) || (`opcode == 7'b0010111) || (`opcode == 7'b1101111) || ((`opcode == 7'b1100111) && (`func3 == 3'b000)) || (`opcode == 7'b1100011) || ((`opcode == 7'b0000011) && (`func3 != 3'b111)) || ((`opcode == 7'b0100011) && (DE_IR[14] == 1'b0)) || (`opcode == 7'b0010011) || (`opcode == 7'b0110011) || (`opcode == 7'b0001111) || (`opcode == 7'b1110011) || ((`opcode == 7'b0011011) && ((`func3 == 3'b001) || (`func3 == 3'b101) || (`func3 == 3'b000))) || ((`opcode == 7'b0111011) && ((`func3 == 3'b001) || (`func3 == 3'b101) || (`func3 == 3'b000))) || (`opcode == 7'b1110011) || (`opcode == 7'b0110011) || (`opcode == 7'b0111011)) ? 1'b0 : 1'b1;
assign FE_IAM = (FE_PC & 64'd3) == 0 ? 1'b0 : 1'b1;

//TODO: figure out stall logic
// if(dep_stall || mem_stall || v_de_br_stall || v_agex_br_stall) {
//     FE_LD_PC = 0;
// } else if(!icache_r && !v_mem_br_stall) {
//     FE_LD_PC = 0;
// } else if (v_mem_br_stall && mem_pcmux == 0) {
//     FE_LD_PC = 0;
// } else { FE_LD_PC = 1; }
assign FE_LD_PC = (mem_stall || v_de_br_stall || v_agex_br_stall || (icache_r && !v_mem_br_stall) || (v_mem_br_stall && !WB_PC_MUX)) ? 'd0 : 'd1;
// if(dep_stall || mem_stall) {
//     LD_DE = 0;
// } else { LD_DE = 1; }
assign FE_LD_DE = (mem_stall) ? 'd0 : 'd1;
assign FE_PC_input = ({DE_CS,WB_PC_MUX} == 2'b01) ? WB_BR_JMP_PC : ({DE_CS,WB_PC_MUX} == 2'b00) ? FE_PC + 'd4 : DE_MTVEC; 
//always@(*) begin
//    if ({DE_CS,WB_PC_MUX} == 2'b00) begin
//        FE_PC_input = PC + 'd4;
//    end
//    case({DE_CS,WB_PC_MUX})
//        2'b01: FE_PC_input = WB_BR_JMP_PC;
//        2'b00: FE_PC_input = PC + 'd4;
//        2'b10: FE_PC_input = DE_MTVEC;
//        2'b11: FE_PC_input = DE_MTVEC;

//        default: 
//        begin
//        end
//    endcase
//end
endmodule