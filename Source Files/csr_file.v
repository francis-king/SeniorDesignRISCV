//Does it always write to the CSR? Added a valid bit. Can change later?
module csr_file(
    input [11:0] DR,
    input [11:0] SR,
    input [63:0] DATA,
    input [63:0] IR,
    input LD_REG,
    input ST_REG,
    input CS,
    input [63:0] BASE_ADDRESS,
    input [63:0] CAUSE,
    input [3:0] PRIVILEGE, //old privilige mode (y) = [1:0]
                           //new privilige mode (x) = [3:2]
    input [63:0] NPC,
    output [63:0] OUT,
    output [63:0] VEC_OUT,
    input CLK
);

parameter RET = {2'b0,PRIVILEGE[3:2],28'h0200073};

reg [63:0] regFile [4095:0];

//csr file will load and store data in the same cycle
always @(posedge CLK) begin
    if(CS)begin

        regFile[{2'b0,PRIVILEGE,8'h42}] <= CAUSE;                                                                       //_Cause register set
        VEC_OUT <= regFile[{2'b0,PRIVILEGE,8'h05}] + (4*(CAUSE[12:0]));                                                 //trap address in vector table
        regFile[{2'b0,PRIVILEGE[3:2],8'h00}][12:11] <= PRIVILEGE[3:2];                                                  //setting _status.xpp
        regFile[{2'b0,PRIVILEGE[3:2],8'h00}][PRIVILEGE[1:0]+4] <= regFile[{2'b0,PRIVILEGE[3:2],8'h00}][PRIVILEGE[3:2]]; //setting _status.xpie to _status.yie
        regFile[{2'b0,PRIVILEGE[3:2],8'h00}][PRIVILEGE[1:0]] <= 0;                                                      //setting _status.xie to 0
        regFile[{2'b0,PRIVILEGE[3:2],8'h41}] <= NPC;                                                                    //saving PC in _PC

    end
    else if(IR == RET)begin
            OUT <= regFile[SR];     
    end
    else begin
        if (ST_REG)begin
            OUT <= regFile[SR];     
        end
        if (LD_REG) begin
            regFile[DR] <= DATA;
        end
    end

end
assign OUT = regFile[SR];
endmodule