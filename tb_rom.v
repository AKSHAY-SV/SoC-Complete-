`timescale 1ns/1ps

module tb_rom;

reg clk;
reg [31:0] addr;
wire [31:0] rdata;

rom DUT(
    .clk(clk),
    .addr(addr),
    .rdata(rdata)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $dumpfile("rom.vcd");
    $dumpvars(0,tb_rom);

    addr = 0;

    #20;

    addr = 32'h00000000;

    #20;

    addr = 32'h00000004;

    #20;

    addr = 32'h00000008;

    #20;

    $finish;

end

endmodule
