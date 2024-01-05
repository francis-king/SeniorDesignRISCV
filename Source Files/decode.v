module decode (
    input [63:0] DE_PC,
    input [31:0] DE_IR,
    input DE_V,
    input [31:0] WB_IR,
    input [63:0] WB_CSRFD,
    input [63:0] WB_DATA,
    input WB_LD_REG,
    input CLK,
    output reg [31:0] EXE_PC,
    output reg [63:0] EXE_CSFRD,
    output reg [63:0] EXE_ALU_ONE,
    output reg [63:0] EXE_ALU_TWO,
    output reg [31:0] EXE_IR,
    output reg EXE_V,
    output reg [63:0] RFD
    output v_de_br_stall,
);

wire [63:0] de_reg_out_one, de_reg_out_two;
register_file regFile (.DR(WB_IR[11:7]), .SR1(DE_IR[19:15]), .SR2(DE_IR[24:20]), .WB_DATA(WB_DATA), .WB_LD_REG(WB_LD_REG), .out_one(out_one), .out_two(out_two), .CLK(CLK));


endmodule