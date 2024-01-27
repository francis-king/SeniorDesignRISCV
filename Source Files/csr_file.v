//Does it always write to the CSR? Added a valid bit. Can change later?
module csr_file(
    input [11:0] DR,
    input [11:0] SR,
    input [63:0] DATA,
    input LD_REG,
    input ST_REG,
    input CS,
    input [63:0] BASE_ADDRESS,
    input [63:0] CAUSE,
    input [1:0] PRIVILEGE,
    input [63:0] NPC,
    output [63:0] OUT,
    output [63:0] MTVEC,
    input CLK
);

reg [63:0] regFile [4095:0];

//csr file will load and store data in the same cycle
always @(posedge CLK) begin
    if(CS)begin

    end
    else begin
        if (ST_REG)begin
            OUT <= regFile[SR]
        end
        if (LD_REG) begin
            regFile[DR] <= DATA;
        end
    end

end
assign OUT = regFile[SR];
endmodule