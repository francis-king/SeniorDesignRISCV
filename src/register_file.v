//Assumes 32 registers are available for use
//Note: Not sure what DE_V is used for in datapath?
module register_file(
    input [4:0] DR,
    input [4:0] SR1,
    input [4:0] SR2,
    input [63:0] WB_DATA,
    input WB_ST_REG,
    input reset,
    output [63:0] out_one,
    output [63:0] out_two,
    input CLK
);

reg [63:0] regFile [31:0];
integer i;
always @(posedge CLK) begin
    if (reset) begin
        for(i = 0; i < 64; i= i+1)
        begin
            regFile[i] <= 32'd0;
        end 
    end else if (WB_ST_REG) begin
        regFile[DR] <= WB_DATA;
    end
end
assign out_one = regFile[SR1];
assign out_two = regFile[SR2];
endmodule