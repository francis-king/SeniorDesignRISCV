//Does it always write to the CSR? Added a valid bit. Can change later?
module csr_file(
    input [4:0] DR,
    input [4:0] SR,
    input [63:0] DATA,
    input LD_REG,
    output [63:0] OUT,
    input CLK
);

reg [63:0] regFile [31:0];

always @(posedge CLK) begin
    if (LD_REG) begin
        regFile[DR] <= DATA;
    end
end
assign OUT = regFile[SR];
endmodule