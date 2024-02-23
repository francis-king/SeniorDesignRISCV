`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 12:49:36 PM
// Design Name: 
// Module Name: execute
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module execute(EXE_NPC, EXE_CSRFD, EXE_ALU1, EXE_ALU2, EXE_IR,
               EXE_V, EXE_RFD, MEM_NPC, MEM_ALU_RESULT, MEM_IR,
               MEM_SR2, MEM_SR1, MEM_V, MEM_CSRFD, MEM_RFD,clk, MEM_STALL, MEM_ECALL, EXE_ECALL, RESET
                );

//`define func3 EXE_IR[14:12];
//`define EXE_IR[30] EXE_EXE_IR[30];
//`define EXE_IR[6:0] EXE_IR[6:0]
//`define EXE_IR[13:12] EXE_IR[13:12];
`define opcode EXE_IR[6:0]
`define func3 EXE_IR[14:12]
`define func7 EXE_IR[31:25]
input clk;
input EXE_V;
input MEM_STALL;
input RESET;
input EXE_ECALL;
input [31:0] EXE_IR;
input [63:0] EXE_NPC, EXE_CSRFD, EXE_ALU1, EXE_ALU2;
input [63:0] EXE_RFD;
output reg MEM_ECALL;
output reg[31:0] MEM_IR;
output reg [63:0] MEM_NPC, MEM_ALU_RESULT, MEM_SR2, MEM_SR1,
              MEM_CSRFD, MEM_RFD;
output reg MEM_V;

wire [31:0] IR;
wire [63:0] alu_A, alu_B, EXE_PC, alu_out, temp, temp_div;
wire [63:0] tempsum, tempshiftright, tempshiftleft, tempsubab, tempblah;
assign tempsum = alu_A + alu_B;
assign tempshiftright = alu_A >> alu_B[4:0];
assign tempshiftleft = alu_A << alu_B[4:0];
assign tempsubab = alu_A - alu_B;
assign tempblah = ((alu_A[31]) ? {32'hFFFFFFFF, alu_A[31:0]} : {32'd0, alu_A[31:0]}) >>> alu_B[4:0];
reg [63:0] shift_out;
wire [127:0] temp_mul_uu, temp_mul_ss, temp_mul_su;
assign EXE_pc = EXE_NPC - 'd4;
assign temp_mul_uu = $unsigned(alu_A) * $unsigned(alu_B);
assign temp_mul_ss = $signed(alu_A) * $signed(alu_B);
assign temp_mul_su = $signed(alu_A) * $unsigned(alu_B);

assign alu_A = ((`opcode == 7'b0000011) || (`opcode == 0010111) ||
                (`opcode == 7'b0100011) || (`opcode == 7'b1101111) ||
                (`opcode == 7'b1100111))? EXE_PC : EXE_ALU1;
assign alu_B = EXE_ALU2;

always @(posedge clk) begin
    if(RESET)begin
        MEM_NPC <= 0;
        MEM_ECALL <= 0;
        MEM_IR <= 0;
        MEM_SR1 <= 0;
        MEM_SR2 <= 0;
        MEM_CSRFD <= 0;
        MEM_RFD <= 0;
        MEM_V <= 0;
        MEM_ALU_RESULT <= 0;
        
    end
    else begin
    if (!MEM_STALL) begin
        MEM_NPC <= EXE_NPC;
        MEM_ECALL <= EXE_ECALL;
        MEM_IR <= EXE_IR;
        MEM_SR1 <= EXE_ALU1;
        MEM_SR2 <= EXE_ALU2;
        MEM_CSRFD <= EXE_CSRFD;
        MEM_RFD <= csrresult;
        MEM_V <= EXE_V;
   
    //LUI
    if (`opcode == 7'b0110111) begin
        MEM_ALU_RESULT <= alu_B;
        //alu_out <= alu_B;
    //AUIPC, JAL, JALR, LD, ST
    end else if ((`opcode == 7'b0010111) || (`opcode == 7'b1101111) || (`opcode == 7'b1100111) || (`opcode == 7'b0000011) || (`opcode == 7'b0100011)) begin
        MEM_ALU_RESULT <= alu_A + alu_B;
    end else if (`opcode == 7'b0010011) begin
        case (`func3)
            3'd0:begin
                MEM_ALU_RESULT <= alu_A + alu_B;
            end
            3'd1: begin
                MEM_ALU_RESULT <= alu_A << alu_B[5:0];
            end
            3'd2:begin
                MEM_ALU_RESULT <= ($signed(alu_A) < $signed(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd3:begin
                MEM_ALU_RESULT <= ($unsigned(alu_A) < $unsigned(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd4: begin
                MEM_ALU_RESULT <= alu_A ^ alu_B;
            end
            3'd5: begin
                if (EXE_IR[30]) begin
                    MEM_ALU_RESULT <= alu_A >>> alu_B[5:0]; 
                end else begin
                    MEM_ALU_RESULT <= alu_A >> alu_B[5:0]; 
                end
            end
            3'd6: begin
                MEM_ALU_RESULT <= alu_A | alu_B;
            end
            3'd7: begin
                MEM_ALU_RESULT <= alu_A & alu_B;
            end
        endcase
    end else if (`opcode == 7'b0110011) begin
        case (`func3)
            3'd0:begin
                if (EXE_IR[30] == 1'b1) begin
                    MEM_ALU_RESULT <= alu_A - alu_B;
                end else begin
                    MEM_ALU_RESULT <= alu_A + alu_B;
                end
            end
            3'd1: begin
                MEM_ALU_RESULT <= alu_A << alu_B[5:0];
            end
            3'd2:begin
                MEM_ALU_RESULT <= ($signed(alu_A) < $signed(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd3:begin
                MEM_ALU_RESULT <= ($unsigned(alu_A) < $unsigned(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd4: begin
                MEM_ALU_RESULT <= alu_A ^ alu_B;
            end
            3'd5: begin
                if (EXE_IR[30]) begin
                    MEM_ALU_RESULT <= alu_A >>> alu_B[5:0]; 
                end else begin
                    MEM_ALU_RESULT <= alu_A >> alu_B[5:0]; 
                end
            end
            3'd6: begin
                MEM_ALU_RESULT <= alu_A | alu_B;
            end
            3'd7: begin
                MEM_ALU_RESULT <= alu_A & alu_B;
            end
        endcase
    end else if (`opcode == 7'b0011011) begin
        case (`func3)
            3'd0: begin
                MEM_ALU_RESULT <= (tempsum[31]) ? {32'hFFFFFFFF, tempsum[31:0]} : {32'd0, tempsum[31:0]};
            end
            3'd1: begin
                MEM_ALU_RESULT <= {32'd0, tempshiftleft[31:0]};
            end
            3'd5: begin
                if (EXE_IR[30]) begin
                    MEM_ALU_RESULT <= {32'd0, tempblah[31:0]};
                end else begin
                    MEM_ALU_RESULT <= {32'd0, tempshiftright[31:0]};
                end
            end
        endcase
    end else if (`opcode == 7'b0111011) begin
        case (`func3)
            3'd0: begin
                if (EXE_IR[30] == 1'b1) begin
                MEM_ALU_RESULT <= (tempsubab[31]) ? {32'hFFFFFFFF, tempsubab[31:0]} : {32'd0, tempsubab[31:0]};    
                end else 
                MEM_ALU_RESULT <= (tempsum[31]) ? {32'hFFFFFFFF, tempsum[31:0]} : {32'd0, tempsum[31:0]};
            end
            3'd1: begin
               MEM_ALU_RESULT <= {32'd0, tempshiftleft[31:0]};
            end
            3'd5: begin
                if (EXE_IR[30]) begin
 
                    MEM_ALU_RESULT <= {32'd0, tempshiftleft[31:0]};
                end else begin
                    MEM_ALU_RESULT <= {32'd0, tempshiftright[31:0]};
                end
            end
        endcase
    end else if (`opcode == 7'b0110011) begin
        case (`func3)
            3'd0: begin
                MEM_ALU_RESULT <= temp_mul_uu[63:0];
            end
            3'd1: begin
                MEM_ALU_RESULT <= temp_mul_ss[127:64];
            end
            3'd2: begin
                MEM_ALU_RESULT <= temp_mul_su[127:64];
            end
            3'd3: begin
                MEM_ALU_RESULT <= temp_mul_uu[127:64];
            end
            3'd4: begin
                MEM_ALU_RESULT <= $signed(alu_A) / $signed(alu_B);
            end
            3'd5: begin
                MEM_ALU_RESULT <= $unsigned(alu_A) / $unsigned(alu_B);
            end
            3'd6: begin
                MEM_ALU_RESULT <= $signed(alu_A) % $signed(alu_B);
            end
            3'd6: begin
                MEM_ALU_RESULT <= $unsigned(alu_A) % $unsigned(alu_B);
            end
        endcase
    end else if (`opcode == 7'b0111011) begin
        case(`func3)
            3'd0: begin
                if (temp_div[63]) begin
                    MEM_ALU_RESULT <= {32'hFFFFFFFF, temp_mul_uu[31:0]};
                end else begin
                    MEM_ALU_RESULT <= {32'd0, temp_mul_uu[31:0]};
                end
            end
            3'd4: begin
                if (temp_div[63]) begin
                    MEM_ALU_RESULT <= {32'hFFFFFFFF, temp_mul_ss[31:0]};
                end else begin
                    MEM_ALU_RESULT <= {32'd0, temp_mul_ss[31:0]};
                end
            end
            3'd5: begin
                MEM_ALU_RESULT <= {32'd0, temp_mul_uu[31:0]};
            end
            3'd6: begin
                if (temp_div[31]) begin
                    MEM_ALU_RESULT <= {32'hFFFFFFFF, temp_mul_ss[31:0]};
                end else begin
                    MEM_ALU_RESULT <= {32'd0, temp_mul_ss[31:0]};
                end
            end
            3'd7: begin
                MEM_ALU_RESULT <= {32'd0, temp_mul_uu[31:0]};
            end
        endcase
    end
    end
end
end
reg [63:0] csrresult = 0;
always @(*) begin
    case(EXE_IR[13:12]) 
        2'b01:csrresult = EXE_RFD; //write
        2'b10:csrresult = EXE_ALU1 | EXE_RFD; //or
        2'b11:csrresult = EXE_ALU1 & EXE_RFD; //and
        default: ;
    endcase
end

endmodule
