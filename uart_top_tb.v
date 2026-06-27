`timescale 1ns / 1ps

module uart_top_tb;

reg clk;
reg rst;

reg tx_start;
reg [7:0] tx_data;

wire [7:0] rx_data;
wire rx_valid;

wire tx_busy;

uart_top DUT(

    .clk(clk),
    .rst(rst),

    .tx_start(tx_start),
    .tx_data(tx_data),

    .rx_data(rx_data),
    .rx_valid(rx_valid),

    .tx_busy(tx_busy)

);

always #5 clk = ~clk;

initial
begin

    $dumpfile("uart_top.vcd");
    $dumpvars(0, uart_top_tb);

    clk = 0;
    rst = 1;

    tx_start = 0;
    tx_data  = 8'h55;

    #20;
    rst = 0;

    #20;

    tx_start = 1;

    #10;

    tx_start = 0;

    #3000;

    $finish;

end

endmodule
