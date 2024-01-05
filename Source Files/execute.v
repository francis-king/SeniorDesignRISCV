`timescale 1ns / 1ps
module execute(exe_PC, exe_CSRFD, exe_ALU1, exe_ALU2, exe_IR,
               exe_V, exe_RFD, mem_PC, mem_ALU_RESULT, mem_IR,
               mem_SR2, mem_SR1, mem_V, mem_CSRFD, mem_RFD,clk, mem_stall
                );

//`define func3 exe_IR[14:12];
//`define exe_IR[30] exe_exe_IR[30];
//`define exe_IR[6:0] exe_IR[6:0]
//`define exe_IR[13:12] exe_IR[13:12];
input clk;
input exe_V;
input mem_stall;
input [31:0] exe_IR;
input [63:0] exe_PC, exe_CSRFD, exe_ALU1, exe_ALU2;
input [63:0] exe_RFD;

output reg[31:0] mem_IR;
output reg [63:0] mem_PC, mem_ALU_RESULT, mem_SR2, mem_SR1,
              mem_CSRFD, mem_RFD;
output reg mem_V;

wire [31:0] IR;
wire [63:0] alu_A, alu_B;
reg [63:0] shift_out;
reg [63:0] alu_out;

assign IR = exe_IR;

assign alu_A = ((IR[6:0] == 7'b1100011) || (IR[6:0] == 7'b0000011) || 
                (IR[6:0] == 7'b0100011) || (IR[6:0] == 7'b1101111) ||
                (IR[6:0] == 7'b1100111))? exe_PC : exe_ALU1;
assign alu_B = exe_ALU2;

always @(*) begin

    if((IR[14:12] == 3'b001) && (IR[6:0] == 7'b0110011))begin //SLLI
        shift_out = alu_A << alu_B[4:0];
    end
    else if((IR[14:12] == 3'b101) && (IR[6:0] == 7'b0110011) && !IR[30]) begin //SRLI
        shift_out = alu_A >> alu_B[4:0];
    end
    else if((IR[14:12] == 3'b101) && (IR[6:0] == 7'b0110011) && IR[30]) begin //SRAI
        shift_out = alu_A >>> alu_B[4:0];
    end
    else
        shift_out = alu_A;

end


always @(*) begin
    
    case (IR[14:12])
        'd0: alu_out = (IR[30])? alu_A - alu_B : alu_A + alu_B;
            
        'd1: alu_out = shift_out;

        'd2: alu_out = ($signed(alu_A) < $signed(alu_B));
        'd3: alu_out = (alu_A < alu_B)? 64'h0000_0001: 64'h0000_0000;
        'd4: alu_out = alu_A ^ alu_B;
        'd5: alu_out = shift_out;
        'd6: alu_out = alu_A | alu_B;
        'd7: alu_out = alu_A & alu_B;
    endcase


end
reg [63:0] csrresult = 0;
always @(*) begin
    case(IR[13:12]) 
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