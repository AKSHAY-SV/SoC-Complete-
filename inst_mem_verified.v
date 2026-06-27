`timescale 1ns / 1ps
module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;
 
    
   initial begin

    // x1 = 0x5000 UART base
    mem[0] = 32'h000050B7;   // lui x1,0x5

    // x2 = 0x41 ('A')
    mem[1] = 32'h04100113;   // addi x2,x0,65

    // write TXDATA
    mem[2] = 32'h0020A023;   // sw x2,0(x1)

    // NOPs
    mem[3] = 32'h00000013;
    mem[4] = 32'h00000013;
    mem[5] = 32'h00000013;
    mem[6] = 32'h00000013;
    mem[7] = 32'h00000013;

    for(i=8;i<256;i=i+1)
        mem[i] = 32'h00000013;

end   
    assign instr = mem[addr[9:2]];
endmodule
