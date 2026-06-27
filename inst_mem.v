`timescale 1ns / 1ps
module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;
 
    
   initial begin

mem[0] = 32'h000030B7;   // x1 = 0x3000 (SPI base)

mem[1] = 32'h00100113;   // x2 = 1
mem[2] = 32'h0020A423;   // sw x2,8(x1) -> control_reg

mem[3] = 32'h00000013;
mem[4] = 32'h00000013;
mem[5] = 32'h00000013;
mem[6] = 32'h00000013;
mem[7] = 32'h00000013;
mem[8] = 32'h00000013;	  

    for(i=8;i<256;i=i+1)
        mem[i] = 32'h00000013;

end   
    assign instr = mem[addr[9:2]];
endmodule
