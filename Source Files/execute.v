`timescale 1ns / 1ps
module execute(exe_NPC, exe_CSRFD, exe_ALU1, exe_ALU2, exe_IR,
               exe_V, exe_RFD, mem_PC, mem_ALU_RESULT, mem_IR,
               mem_SR2, mem_SR1, mem_V, mem_CSRFD, mem_RFD,clk, mem_stall
                );

//`define func3 exe_IR[14:12];
//`define exe_IR[30] exe_exe_IR[30];
//`define exe_IR[6:0] exe_IR[6:0]
//`define exe_IR[13:12] exe_IR[13:12];
`define opcode exe_IR[6:0]
`define func3 exe_IR[14:12]
`define func7 exe_IR[31:25]
input clk;
input exe_V;
input mem_stall;
input [31:0] exe_IR;
input [63:0] exe_NPC, exe_CSRFD, exe_ALU1, exe_ALU2;
input [63:0] exe_RFD;

output reg[31:0] mem_IR;
output reg [63:0] mem_PC, mem_ALU_RESULT, mem_SR2, mem_SR1,
              mem_CSRFD, mem_RFD;
output reg mem_V;

wire [31:0] IR;
wire [63:0] alu_A, alu_B, exe_pc, alu_out, temp, temp_div;
reg [63:0] shift_out;
wire [127:0] temp_mul;
assign exe_pc = exe_NPC - 'd4;

assign alu_A = ((`opcode == 7'b0000011) || (`opcode == 0010111)
                (`opcode == 7'b0100011) || (`opcode == 7'b1101111) ||
                (`opcode == 7'b1100111))? exe_PC : exe_ALU1;
assign alu_B = exe_ALU2;

always @(*) begin
    //LUI
    if (`opcode == 7'b0110111) begin
        alu_out = alu_B;
    //AUIPC, JAL, JALR, LD, ST
    end else if ((`opcode == 7'b0010111) || (`opcode == 7'b1101111) || (`opcode == 7'b1100111) || (`opcode == 7'b0000011) || (`opcode == 7'b0100011)) begin
        alu_out = alu_A + alu_B;
    end else if (`opcode == 7'b0010011) begin
        case (func3)
            3'd0:begin
                alu_out = alu_A + alu_B;
            end
            3'd1: begin
                alu_out = alu_A << alu_B[5:0];
            end
            3'd2:begin
                alu_out = ($signed(alu_A) < $signed(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd3:begin
                alu_out = ($unsigned(alu_A) < $unsigned(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd4: begin
                alu_out = alu_A ^ alu_B;
            end
            3'd5: begin
                if (exe_IR[30]) begin
                    alu_out = alu_A >>> alu_B[5:0]; 
                end else begin
                    alu_out = alu_A >> alu_B[5:0]; 
                end
            end
            3'd6: begin
                alu_out = alu_A | alu_B;
            end
            3'd7: begin
                alu_out = alu_A & alu_B;
            end
        endcase
    end else if (`opcode == 7'b0110011) begin
        case (func3)
            3'd0:begin
                if (exe_IR[30] == 1'b1) begin
                    alu_out = alu_A - alu_B;
                end else begin
                    alu_out = alu_A + alu_B;
                end
            end
            3'd1: begin
                alu_out = alu_A << alu_B[5:0];
            end
            3'd2:begin
                alu_out = ($signed(alu_A) < $signed(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd3:begin
                alu_out = ($unsigned(alu_A) < $unsigned(alu_B)) ? (1'd1) : 1'd0;
            end
            3'd4: begin
                alu_out = alu_A ^ alu_B;
            end
            3'd5: begin
                if (exe_IR[30]) begin
                    alu_out = alu_A >>> alu_B[5:0]; 
                end else begin
                    alu_out = alu_A >> alu_B[5:0]; 
                end
            end
            3'd6: begin
                alu_out = alu_A | alu_B;
            end
            3'd7: begin
                alu_out = alu_A & alu_B;
            end
        endcase
    end else if (`opcode == 7'b0011011) begin
        case (func3)
            3'd0: begin
                temp = alu_A + alu_B;
                alu_out = (temp[31]) ? {32'hFFFFFFFF, temp[31:0]} : {32'd0, temp[31:0]};
            end
            3'd1: begin
                temp = alu_A << alu_B[4:0];
                alu_out = {32'd0, temp[31:0]};
            end
            3'd5: begin
                if (exe_IR[30]) begin
                    temp = ((alu_A[31]) ? {32'hFFFFFFFF, alu_A[31:0]} : {32'd0, alu_A[31:0]}) >>> alu_B[4:0]; 
                    alu_out = {32'd0, temp[31:0]};
                end else begin
                    temp =  alu_A >> alu_B[4:0]; 
                    alu_out = {32'd0, temp[31:0]};
                end
            end
        endcase
    end else if (`opcode == 7'b0111011) begin
        case (func3)
            3'd0: begin
                if (exe_IR[30] == 1'b1) begin
                    temp = alu_A - alu_B;
                end else begin
                    temp = alu_A + alu_B;
                end
                alu_out = (temp[31]) ? {32'hFFFFFFFF, temp[31:0]} : {32'd0, temp[31:0]};
            end
            3'd1: begin
                temp = alu_A << alu_B[4:0];
                alu_out = {32'd0, temp[31:0]};
            end
            3'd5: begin
                if (exe_IR[30]) begin
                    temp = ((alu_A[31]) ? {32'hFFFFFFFF, alu_A[31:0]} : {32'd0, alu_A[31:0]}) >>> alu_B[4:0]; 
                    alu_out = {32'd0, temp[31:0]};
                end else begin
                    temp =  alu_A >> alu_B[4:0]; 
                    alu_out = {32'd0, temp[31:0]};
                end
            end
        endcase
    end else if (`opcode == 7'b0110011) begin
        case (func3)
            3'd0: begin
                temp_mul = alu_A * alu_B;
                alu_out = temp_mul[63:0];
            end
            3'd1: begin
                temp_mul = $signed(alu_A) * $signed(alu_B);
                alu_out = temp_mul[127:64];
            end
            3'd2: begin
                temp_mul = $signed(alu_A) * $unsigned(alu_B);
                alu_out = temp_mul[127:64];
            end
            3'd3: begin
                temp_mul = $unsigned(alu_A) * $unsigned(alu_B);
                alu_out = temp_mul[127:64];
            end
            3'd4: begin
                alu_out = $signed(alu_A) / $signed(alu_B);
            end
            3'd5: begin
                alu_out = $unsigned(alu_A) / $unsigned(alu_B);
            end
            3'd6: begin
                alu_out = $signed(alu_A) % $signed(alu_B);
            end
            3'd6: begin
                alu_out = $unsigned(alu_A) % $unsigned(alu_B);
            end
        endcase
    end else if (`opcode == 7'b0111011) begin
        case(func3)
            3'd0: begin
                temp_mul = alu_A[31:0] * alu_B[31:0];
                if (temp_div[63]) begin
                    alu_out = {32'hFFFFFFFF, temp_mul[31:0]};
                end else begin
                    alu_out = {32'd0, temp_mul[31:0]};
                end
            end
            3'd4: begin
                temp_mul = $signed(alu_A[31:0]) / $signed(alu_B[31:0]);
                if (temp_div[63]) begin
                    alu_out = {32'hFFFFFFFF, temp_mul[31:0]};
                end else begin
                    alu_out = {32'd0, temp_mul[31:0]};
                end
            end
            3'd5: begin
                temp_mul = $unsigned(alu_A[31:0]) / $unsigned(alu_B[31:0]);
                alu_out = {32'd0, temp_mul[31:0]};
            end
            3'd6: begin
                temp_mul = $signed(alu_A[31:0]) % $signed(alu_B[31:0]);
                if (temp_div[31]) begin
                    alu_out = {32'hFFFFFFFF, temp_mul[31:0]};
                end else begin
                    alu_out = {32'd0, temp_mul[31:0]};
                end
            end
            3'd7: begin
                temp_mul = $unsigned(alu_A[31:0])%/ $unsigned(alu_B[31:0]);
                alu_out = {32'd0, temp_mul[31:0]};
            end
        endcase
    end
end

wire [63:0] csrresult = 0;
always @(*) begin
    case(DE_IR[13:12]) 
        2'b01:csrresult = exe_RFD; //write
        2'b10:csrresult = exe_ALU1 | exe_RFD; //or
        2'b11:csrresult = exe_ALU1 & exe_RFD; //and
        default: ;
    endcase
end

always @(posedge clk) begin
    if (!mem_stall) begin
        mem_PC <= exe_PC;
        mem_ALU_RESULT <= alu_out;
        mem_IR <= exe_IR;
        mem_SR1 <= exe_ALU1;
        mem_SR2 <= exe_ALU2;
        mem_CSRFD <= exe_CSRFD;
        mem_RFD <= csrresult;
        mem_V <= exe_V;
    end
end
endmodule