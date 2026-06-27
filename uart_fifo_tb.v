`timescale 1ns / 1ps

module uart_fifo_tb;

reg clk;
reg rst;

reg wr_en;
reg rd_en;

reg [7:0] din;

wire [7:0] dout;

wire full;
wire empty;

uart_fifo DUT(

    .clk(clk),
    .rst(rst),

    .wr_en(wr_en),
    .rd_en(rd_en),

    .din(din),

    .dout(dout),

    .full(full),
    .empty(empty)

);

always #5 clk = ~clk;

initial
begin

    $dumpfile("uart_fifo.vcd");
    $dumpvars(0, uart_fifo_tb);

    clk = 0;
    rst = 1;

    wr_en = 0;
    rd_en = 0;

    din = 0;

    #20;
    rst = 0;

    // Write A1

    #10;
    din = 8'hA1;
    wr_en = 1;

    #10;
    wr_en = 0;

    // Write B2

    #20;
    din = 8'hB2;
    wr_en = 1;

    #10;
    wr_en = 0;

    // Read first

    #20;
    rd_en = 1;

    #10;
    rd_en = 0;

    // Read second

    #20;
    rd_en = 1;

    #10;
    rd_en = 0;

    #100;

    $finish;

end

endmodule
