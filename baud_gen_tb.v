`timescale 1ns / 1ps

module baud_gen_tb;

reg clk;
reg rst;

reg [15:0] baud_div;

wire baud_tick;

baud_gen DUT(

    .clk(clk),
    .rst(rst),
    .baud_div(baud_div),
    .baud_tick(baud_tick)

);

always #5 clk = ~clk;

initial
begin

    $dumpfile("baud_gen.vcd");
    $dumpvars(0, baud_gen_tb);

    clk = 0;
    rst = 1;

    baud_div = 10;

    #20;

    rst = 0;

    #300;

    $finish;

end

endmodule
