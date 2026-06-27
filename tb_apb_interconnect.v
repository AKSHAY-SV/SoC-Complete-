`timescale 1ns/1ps

module tb_apb_interconnect;

reg psel;
reg penable;
reg pwrite;

reg [31:0] paddr;
reg [31:0] pwdata;

wire [31:0] prdata;
wire pready;

wire gpio_psel;
wire timer_psel;

apb_interconnect DUT (

    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),

    .prdata(prdata),
    .pready(pready),

    .gpio_psel(gpio_psel),
    .gpio_penable(),
    .gpio_pwrite(),
    .gpio_paddr(),
    .gpio_pwdata(),
    .gpio_prdata(32'hAAAA5555),
    .gpio_pready(1'b1),

    .timer_psel(timer_psel),
    .timer_penable(),
    .timer_pwrite(),
    .timer_paddr(),
    .timer_pwdata(),
    .timer_prdata(32'h12345678),
    .timer_pready(1'b1)

);

initial begin

    $dumpfile("apb_interconnect.vcd");
    $dumpvars(0,tb_apb_interconnect);

    psel=1;
    penable=1;
    pwrite=0;
    pwdata=0;

    //--------------------------------
    // GPIO
    //--------------------------------

    paddr=32'h0000_0004;

    #10;

    $display("GPIO_SEL=%b TIMER_SEL=%b DATA=%h",
             gpio_psel,timer_psel,prdata);

    //--------------------------------
    // TIMER
    //--------------------------------

    paddr=32'h0000_1004;

    #10;

    $display("GPIO_SEL=%b TIMER_SEL=%b DATA=%h",
             gpio_psel,timer_psel,prdata);

    #20;

    $finish;

end

endmodule
