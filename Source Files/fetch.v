module fetch (
    input [1:0] MEM_PCMUX,
    input [63:0] WB_BR_JMP_PC,
    input [63:0] DE_MTVEC,
    input DE_CS,
    input v_de_br_stall,
    input v_agex_br_stall,
    input v_mem_br_stall,
    input reset,
    input CLK,
    output reg [63:0] DE_NPC,
    output reg [31:0] DE_IR,
    output reg DE_V,
    output F_IAM,
    output F_IAF,
    output F_II
);

`define opcode DE_IR[6:0]
`define func3 DE_IR[14:12]
//TODO:IAM signals
reg [63:0] FE_PC;
wire FE_LD_PC, FE_LD_DE;
wire [63:0] FE_PC_input;

always @(posedge CLK) begin
    if (reset) begin
        FE_PC <= 'd0;
    end else if (FE_LD_PC) begin
        FE_PC <= FE_PC_input;
    end
    if (LD_DE) begin
        DE_V = icache_r && !v_de_br_stall && !v_agex_br_stall && !v_mem_br_stall;;
        DE_IR = FE_instruction;
        DE_NPC = FE_PC + 4;
    end
end

reg [31:0] FE_instruction;

instruction_cache a0 (.PC(FE_PC), .cache_hit(cache_hit), .instruction(FE_instruction));

assign F_IAF = ~cache_hit;
assign FE_II = ((`opcode == 7'b0110111) || (`opcode == 7'b0010111) || (`opcode == 7'b1101111) || ((`opcode == 7'b1100111) && (`func3 == 3'b000)) || (`opcode == 7'b1100011) || ((`opcode == 7'b0000011) && (`func3 != 3'b111)) || ((`opcode == 7'b0100011) && (DE_IR[14] == 1'b0)) || (`opcode == 7'b0010011) || (`opcode == 7'b0110011) || (`opcode == 7'b0001111) || (`opcode == 7'b1110011) || ((`opcode == 7'b0011011) && ((`func3 == 3'b001) || (`func3 == 3'b101) || (`func3 == 3'b000))) || ((`opcode == 7'b0111011) && ((`func3 == 3'b001) || (`func3 == 3'b101) || (`func3 == 3'b000))) || (`opcode == 7'b1110011) || (`opcode == 7'b0110011) || (`opcode == 7'b0111011)) ? 1'b0 : 1'b1;

// if(dep_stall || mem_stall || v_de_br_stall || v_agex_br_stall) {
//     FE_LD_PC = 0;
// } else if(!icache_r && !v_mem_br_stall) {
//     FE_LD_PC = 0;
// } else if (v_mem_br_stall && mem_pcmux == 0) {
//     FE_LD_PC = 0;
// } else { FE_LD_PC = 1; }
assign FE_LD_PC = (mem_stall || v_de_br_stall || v_agex_br_stall || (icache_r && !v_mem_br_stall) || (v_mem_br_stall && !mem_pcmux)) ? 'd0 : 'd1;
// if(dep_stall || mem_stall) {
//     LD_DE = 0;
// } else { LD_DE = 1; }
assign FE_LD_DE = (mem_stall) ? 'd0 : 'd1;

always@(*) begin
    case({DE_CS,MEM_PCMUX})
        2'b01: FE_PC_input = WB_BR_JMP_PC;
        2'b02: FE_PC_input = PC + 'd4;
        2'b1x: FE_PC_input = DE_MTVEC;
        default: 
    endcase
end
endmodule