module instruction_cache (
    input [63:0] PC,
    output icache_r,
    output [31:0] instruction
);

reg [63:12] cacheAddress;
//Page Size of 2^12 byte sized elements
reg [7:0] page [4095:0];

// if (PC[63:12] == cacheAddress){
//     icache_r = 1;
// } else{
//     icache_r = 0;
// }
assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;

assign instruction = {page[{PC[11:3],'b11}], page[{PC[11:3],'b10}], page[{PC[11:3],'b01}], page[{PC[11:3],'b00}]};
assign page = 0;
//add in code to talk to memory bus


endmodule