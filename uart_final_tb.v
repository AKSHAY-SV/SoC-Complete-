`timescale 1ns / 1ps

module uart_final_tb;

reg PCLK;
reg PRESETn;

reg PSEL;
reg PENABLE;
reg PWRITE;

reg [7:0]  PADDR;
reg [31:0] PWDATA;

wire [31:0] PRDATA;
wire PREADY;

wire uart_tx;
wire uart_rx;

/* Loopback */
assign uart_rx = uart_tx;

uart_final DUT(

    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),

    .PADDR(PADDR),
    .PWDATA(PWDATA),

    .PRDATA(PRDATA),
    .PREADY(PREADY),

    .uart_rx(uart_rx),
    .uart_tx(uart_tx)

);

always #5 PCLK = ~PCLK;

task apb_write;
input [7:0] addr;
input [31:0] data;
begin

    @(posedge PCLK);
    PADDR   <= addr;
    PWDATA  <= data;
    PWRITE  <= 1'b1;
    PSEL    <= 1'b1;
    PENABLE <= 1'b0;

    @(posedge PCLK);
    PENABLE <= 1'b1;

    @(posedge PCLK);
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;
    PWRITE  <= 1'b0;

end
endtask

task apb_read;
input [7:0] addr;
begin

    @(posedge PCLK);
    PADDR   <= addr;
    PWRITE  <= 1'b0;
    PSEL    <= 1'b1;
    PENABLE <= 1'b0;

    @(posedge PCLK);
    PENABLE <= 1'b1;

    @(posedge PCLK);
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;

end
endtask

initial
begin

    $dumpfile("uart_final.vcd");
    $dumpvars(0, uart_final_tb);

    PCLK    = 0;
    PRESETn = 0;

    PSEL    = 0;
    PENABLE = 0;
    PWRITE  = 0;

    PADDR   = 0;
    PWDATA  = 0;

    #50;
    PRESETn = 1;

    /* baud_div = 10 */
    apb_write(8'h04,32'd10);

    /* TX_DATA = 0x55 */
    apb_write(8'h00,32'h55);

    #3000;

    /* STATUS */
    apb_read(8'h08);

    #50;

    /* RX_DATA */
    apb_read(8'h00);

    #200;

    $finish;

end

endmodule
