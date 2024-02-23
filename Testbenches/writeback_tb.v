`timescale 1ns / 1ps

module writeback_tb();
    reg CLK, RESET,WB_PC_MUX,WB_V,WB_ECALL,FE_IAM,FE_IAF,FE_II,MEM_LAM,MEM_LAF,MEM_SAM,MEM_SAF,TIMER,EXTERNAL,PRIVILEGE;
    reg [63:0] WB_NPC, WB_MEM_RESULT,WB_ALU_RESULT,WB_CSRFD, WB_RFD;
    reg [31:0] WB_IR;
    reg [4:0] WB_DRID;
    
    wire [63:0] WB_RF_DATA, WB_CSR_DATA, WB_BR_JMP_TARGET, WB_IR_OUT, WB_CAUSE;
    wire [4:0] WB_DRID_OUT;
    wire WB_PC_MUX_OUT, WB_ST_REG, WB_ST_CSR, WB_CS;
    
    writeback m1(.CLK(CLK),
    .RESET(RESET),
    .WB_NPC(WB_NPC),
    .WB_MEM_RESULT(WB_MEM_RESULT),
    .WB_ALU_RESULT(WB_ALU_RESULT),
    .WB_IR(WB_IR),
    .WB_PC_MUX(WB_PC_MUX),
    .WB_V(WB_V),
    .WB_CSRFD(WB_CSRFD),
    .WB_RFD(WB_RFD),
    .WB_DRID(WB_DRID),
    .WB_ECALL(WB_ECALL),
    .FE_IAM(FE_IAM),
    .FE_IAF(FE_IAF),
    .FE_II(FE_II),
    .MEM_LAM(MEM_LAM),
    .MEM_LAF(MEM_LAF),
    .MEM_SAM(MEM_SAM),
    .MEM_SAF(MEM_SAF),
    .TIMER(TIMER),
    .EXTERNAL(EXTERNAL),
    .PRIVILEGE(PRIVILEGE),
    .WB_RF_DATA(WB_RF_DATA),
    .WB_CSR_DATA(WB_CSR_DATA),
    .WB_BR_JMP_TARGET(WB_BR_JMP_TARGET),
    .WB_DRID_OUT(WB_DRID_OUT),
    .WB_PC_MUX_OUT(WB_PC_MUX_OUT),
    .WB_IR_OUT(WB_IR_OUT),
    .WB_ST_REG(WB_ST_REG),
    .WB_ST_CSR(WB_ST_CSR),
    .WB_CAUSE(WB_CAUSE),
    .WB_CS(WB_CS)
    );
    
    initial begin
    CLK = 0;
    RESET = 0;
    WB_PC_MUX = 0;
    WB_V = 0;
    WB_ECALL = 0;
    FE_IAM = 0;
    FE_IAF = 0;
    FE_II = 0;
    MEM_LAM = 0;
    MEM_LAF = 0;
    MEM_SAM = 0;
    MEM_SAF = 0;
    TIMER = 0;
    EXTERNAL = 0;
    PRIVILEGE = 0;
    WB_NPC = 0;
    WB_MEM_RESULT = 0;
    WB_ALU_RESULT = 0;
    WB_CSRFD = 0;
    WB_RFD = 0;
    WB_IR = 0;
    WB_DRID = 0;
    PRIVILEGE = 0;
    WB_ECALL = 0;
    FE_IAM = 0;
    FE_IAF = 0;
    FE_II = 0;
    MEM_LAM = 0;
    MEM_LAF = 0;
    MEM_SAM = 0;
    MEM_SAF = 0;
    TIMER = 0;
    EXTERNAL = 0;
    WB_CSRFD = 0;
    WB_RFD = 0;
    
    #50
    
    WB_PC_MUX = 0;
    WB_V = 1;
    WB_NPC = 0;
    WB_MEM_RESULT = 0;
    WB_ALU_RESULT = 5;
    WB_IR = 32'h00508093;
    WB_DRID = 1;
    
    end
    
always #5 CLK = ~CLK;    
endmodule
