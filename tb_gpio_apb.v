`timescale 1ns/1ps

module tb_gpio_apb;

reg         pclk;
reg         presetn;

reg         psel;
reg         penable;
reg         pwrite;
reg [31:0]  paddr;
reg [31:0]  pwdata;

wire [31:0] prdata;
wire        pready;

wire [7:0] gpio;

gpio_apb DUT (
    .pclk(pclk),
    .presetn(presetn),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .gpio(gpio)
);

initial
begin
    pclk = 0;
    forever #5 pclk = ~pclk;
end

task apb_write;
input [31:0] addr;
input [31:0] data;
begin

    @(posedge pclk);

    psel    = 1;
    pwrite  = 1;
    penable = 0;
    paddr   = addr;
    pwdata  = data;

    @(posedge pclk);

    penable = 1;

    @(posedge pclk);

    psel    = 0;
    penable = 0;
    pwrite  = 0;

end
endtask

task apb_read;
input [31:0] addr;
begin

    @(posedge pclk);

    psel    = 1;
    pwrite  = 0;
    penable = 0;
    paddr   = addr;

    @(posedge pclk);

    penable = 1;

    @(posedge pclk);

    $display("READ Addr=%h Data=%h",addr,prdata);

    psel    = 0;
    penable = 0;

end
endtask

initial
begin

    $dumpfile("gpio.vcd");
    $dumpvars(0,tb_gpio_apb);

    psel    = 0;
    penable = 0;
    pwrite  = 0;
    paddr   = 0;
    pwdata  = 0;

    presetn = 0;

    repeat(5) @(posedge pclk);

    presetn = 1;

    $display("================================");
    $display("TEST 1 : WRITE DIR");
    $display("================================");

    apb_write(32'h04,32'hFF);

    $display("================================");
    $display("TEST 2 : WRITE DATA");
    $display("================================");

    apb_write(32'h00,32'hA5);

    $display("================================");
    $display("TEST 3 : READ DIR");
    $display("================================");

    apb_read(32'h04);

    $display("================================");
    $display("TEST 4 : READ DATA");
    $display("================================");

    apb_read(32'h00);

    #100;

    $finish;

end

endmodule
