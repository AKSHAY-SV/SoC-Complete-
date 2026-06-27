`timescale 1ns/1ps

module tb_plic_simple;

reg pclk;
reg presetn;

reg psel;
reg penable;
reg pwrite;

reg [31:0] paddr;
reg [31:0] pwdata;

wire [31:0] prdata;
wire pready;

reg timer_irq;
reg gpio_irq;

wire cpu_irq;

plic_simple DUT (

    .pclk(pclk),
    .presetn(presetn),

    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),

    .prdata(prdata),
    .pready(pready),

    .timer_irq(timer_irq),
    .gpio_irq(gpio_irq),

    .cpu_irq(cpu_irq)

);

initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
end

task apb_write;
input [31:0] addr;
input [31:0] data;
begin

    @(posedge pclk);

    psel=1;
    pwrite=1;
    penable=0;

    paddr=addr;
    pwdata=data;

    @(posedge pclk);

    penable=1;

    @(posedge pclk);

    psel=0;
    penable=0;
    pwrite=0;

end
endtask

initial begin

    $dumpfile("plic.vcd");
    $dumpvars(0,tb_plic_simple);

    psel=0;
    penable=0;
    pwrite=0;
    paddr=0;
    pwdata=0;

    timer_irq=0;
    gpio_irq=0;

    presetn=0;

    repeat(5) @(posedge pclk);

    presetn=1;

    //-----------------------------------
    // Enable Timer IRQ
    //-----------------------------------

    apb_write(32'h04,32'h1);

    //-----------------------------------
    // Generate Timer IRQ
    //-----------------------------------

    @(posedge pclk);
    timer_irq=1;

    @(posedge pclk);
    timer_irq=0;

    #20;

    if(cpu_irq)
        $display("CPU IRQ GENERATED");
    else
        $display("CPU IRQ FAILED");

    //-----------------------------------
    // Clear Pending
    //-----------------------------------

    apb_write(32'h00,32'h1);

    #20;

    if(!cpu_irq)
        $display("IRQ CLEARED");
    else
        $display("IRQ CLEAR FAILED");

    #50;

    $finish;

end

endmodule
