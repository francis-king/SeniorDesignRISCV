`timescale 1ns / 1ps
module execute(
    input        CLK,
    input [63:0] EXE_NPC,
    input [63:0] EXE_CSRFD,
    input [63:0] EXE_ALU_ONE,
    input [63:0] EXE_ALU_TWO,
    input [31:0] EXE_IR,
    input        EXE_V,
    input        EXE_ECALL,
    input [63:0] EXE_RFD,
    
    output reg [63:0] MEM_PC,
    output reg [63:0] MEM_ALU_RESULT,
    output reg [31:0] MEM_IR,
    output reg [63:0] MEM_SR2,
    output reg [63:0] MEM_SR1,
    output reg        MEM_V,
    output reg [63:0] MEM_CSRFD,
    output reg [63:0] MEM_RFD,
    output reg        MEM_stall,
    output reg        MEM_ECALL
                );

//`define func3 EXE_IR[14:12];
//`define EXE_IR[30] EXE_EXE_IR[30];
//`define EXE_IR[6:0] EXE_IR[6:0]
//`define EXE_IR[13:12] EXE_IR[13:12];
`define opcode EXE_IR[6:0]
`define func3 EXE_IR[14:12]
`define func7 EXE_IR[31:25]


wire [31:0] IR;
wire [63:0] alu_A, alu_B, EXE_pc, alu_out, temp, temp_div;
reg [63:0] shift_out;
wire [127:0] temp_mul;
assign EXE_pc = EXE_NPC - 'd4;

assign alu_A = ((`opcode == 7'b0000011) || (`opcode == 0010111)
                (`opcode == 7'b0100011) || (`opcode == 7'b1101111) ||
                (`opcode == 7'b1100111))? EXE_PC : EXE_ALU_ONE;
assign alu_B = EXE_ALU_TWO;

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
                if (EXE_IR[30]) begin
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
                if (EXE_IR[30] == 1'b1) begin
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
                if (EXE_IR[30]) begin
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
                if (EXE_IR[30]) begin
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
                if (EXE_IR[30] == 1'b1) begin
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
                if (EXE_IR[30]) begin
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
        2'b01:csrresult = EXE_RFD; //write
        2'b10:csrresult = EXE_ALU_ONE | EXE_RFD; //or
        2'b11:csrresult = EXE_ALU_ONE & EXE_RFD; //and
        default: ;
    endcase
end

always @(posedge CLK) begin
    if (!MEM_stall) begin
        MEM_PC <= EXE_PC;
        MEM_ALU_RESULT <= alu_out;
        MEM_IR <= EXE_IR;
        MEM_SR1 <= EXE_ALU_ONE;
        MEM_SR2 <= EXE_ALU_TWO;
        MEM_CSRFD <= EXE_CSRFD;
        MEM_RFD <= csrresult;
        MEM_V <= EXE_V;
        MEM_ECALL <= EXE_ECALL;
    end
end
endmodule