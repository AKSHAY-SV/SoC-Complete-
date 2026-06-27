`timescale 1ns / 1ps

module uart_rx_tb;

reg clk;
reg rst;

reg baud_tick;
reg rx;

wire [7:0] rx_data;
wire rx_valid;

uart_rx DUT(

    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .rx(rx),

    .rx_data(rx_data),
    .rx_valid(rx_valid)

);

always #5 clk = ~clk;

always
begin
    #50 baud_tick = 1;
    #10 baud_tick = 0;
end

initial
begin

    $dumpfile("uart_rx.vcd");
    $dumpvars(0, uart_rx_tb);

    clk = 0;
    rst = 1;

    baud_tick = 0;
    rx = 1;

    #20;
    rst = 0;

    // Start bit
    #40 rx = 0;

    // 0x55 = 01010101
    #60 rx = 1; // bit0
    #60 rx = 0; // bit1
    #60 rx = 1; // bit2
    #60 rx = 0; // bit3
    #60 rx = 1; // bit4
    #60 rx = 0; // bit5
    #60 rx = 1; // bit6
    #60 rx = 0; // bit7

    // Stop bit
    #60 rx = 1;

    #200;

    $finish;

end

endmodule
