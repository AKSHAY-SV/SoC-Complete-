`timescale 1ns / 1ps
module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;
 
    
   initial begin
    mem[0] = 32'h00100093; // addi x1,x0,1
mem[1] = 32'h000010B7; // lui  x1,0x1      -> x1=0x1000
mem[2] = 32'h00100113; // addi x2,x0,1
mem[3] = 32'h0020A023; // sw x2,0(x1)
mem[4] = 32'h00000013; // nop

    for(i=6;i<256;i=i+1)
        mem[i] = 32'h00000013;
end
 
   
    assign instr = mem[addr[9:2]];
endmodule
