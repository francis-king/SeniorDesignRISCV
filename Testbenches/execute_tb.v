`timescale 1ns / 1ps

module execute_tb();
    reg clk;
    reg exe_V;
    reg mem_stall;
    reg [31:0] exe_IR;
    reg [63:0] exe_PC, exe_CSRFD, exe_ALU1, exe_ALU2;
    reg [63:0] exe_RFD;
    
    wire mem_V;
    wire [31:0] mem_IR;
    wire [63:0] mem_PC,mem_ALU_RESULT,  mem_SR2, mem_SR1, mem_CSRFD, mem_RFD;
    
    execute m1(.clk(clk),
  .exe_V(exe_V),
  .mem_stall(mem_stall),
  .exe_IR(exe_IR),
  .exe_PC(exe_PC),
  .exe_CSRFD(exe_CSRFD),
  .exe_ALU1(exe_ALU1),
  .exe_ALU2(exe_ALU2),
  .exe_RFD(exe_RFD),
  .mem_V(mem_V),
  .mem_PC(mem_PC),
  .mem_ALU_RESULT(mem_ALU_RESULT),
  .mem_IR(mem_IR),
  .mem_SR2(mem_SR2),
  .mem_SR1(mem_SR1),
  .mem_CSRFD(mem_CSRFD),
  .mem_RFD(mem_RFD)
  );
    
    initial begin
    clk = 0;
    exe_V = 0;
    mem_stall = 0;
    exe_IR = 0;
    exe_PC = 0;
    exe_CSRFD = 0;
    exe_ALU1 = 0;
    exe_ALU2 = 0;
    exe_RFD = 0;
    
    #50
    
 
    exe_ALU1 = 0;
    exe_ALU2 = 0;
    
    
    exe_IR = 32'h00007013; //ANDI R0, R0, #0
    
    #50
    exe_PC = 4;
    exe_ALU1 = 0;
    exe_ALU2 = 5;
    exe_IR = 32'h00500033; //ADDI R0, R0, #5
    
    #50
    exe_PC = 8;
    exe_ALU1 = 5;
    exe_ALU2 = 5;
    exe_IR = 32'h00000033; //ADD R0, R0, R0
    
    #50
    exe_PC = 12;
    exe_ALU1 = 5;
    exe_ALU2 = 64'hFFFFFFFFFFFFFFFF;
    exe_IR = 32'hFFF06013; //OR R0, R0, xFFFF
    
    #50
    exe_PC = 16;
    exe_ALU1 = 5;
    exe_ALU2 = 10;
    exe_IR = 32'h00002033; //SLT, R1, R2 (R1 less than R2)
    
    #50
    exe_PC = 20;
    exe_ALU1 = 2;
    exe_ALU2 = 4;
    exe_IR = 32'h40002833; //SRA, R2 , R1(Shift 100 by 2, but does wrap around)
    
    #50
    exe_PC = 24;
    exe_ALU1 = 5;
    exe_ALU2 = 2;
    exe_IR = 32'h40000033; //SUB, R2 , R1(Subtract 5 by 2)
    end
    
    
    
always #5 clk = ~clk;
endmodule
