`timescale 1ns / 1ps

module tb_add();
reg CLK;
reg RESET;
reg TIMER;
reg UART_INT;

top DUT(.CLK(CLK),.RESET(RESET),.TIMER(TIMER),.UART_INT(UART_INT));

initial begin
CLK = 1'b0;
RESET = 1'b1;
TIMER = 1'b0;
UART_INT = 1'b0;

#20 RESET = 1'b0;
end

always #5 CLK = ~CLK; 


endmodule
