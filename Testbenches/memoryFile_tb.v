module memoryFile_tb();

reg MEM_V, CLK, reset, we;
reg [63:0] mem_data, address;
wire v_mem_stall;
wire [63:0] data_out;
memoryFile m0 (.MEM_V(MEM_V), .CLK(CLK), .reset(reset), .we(we), .mem_data(mem_data), .address(address), .v_mem_stall(v_mem_stall), .data_out(data_out));

initial begin
    MEM_V <= 1'b1;
    CLK <= 1'b1;
    reset <= 1'b1;
    we <= 1'b0;
    mem_data <= 64'd67;
    address <= 64'd0;

    #10

    reset <= 1'b0;
    we <= 1'b1;

    #10

    we <= 1'b0;
end

always begin
    #5 CLK <= !CLK;
end
endmodule