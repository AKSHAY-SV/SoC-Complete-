`timescale 1ns/1ps

module tb_timer_apb;

reg pclk;
reg presetn;

reg psel;
reg penable;
reg pwrite;

reg [31:0] paddr;
reg [31:0] pwdata;

wire [31:0] prdata;
wire pready;
wire irq;

timer_apb DUT(
    .pclk(pclk),
    .presetn(presetn),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .irq(irq)
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

    $dumpfile("timer.vcd");
    $dumpvars(0,tb_timer_apb);

    presetn=0;
    psel=0;
    penable=0;
    pwrite=0;

    repeat(5) @(posedge pclk);

    presetn=1;

    $display("LOAD=10");

    apb_write(32'h00,32'd10);

    $display("ENABLE TIMER");

    apb_write(32'h08,32'h1);

    wait(irq);

    $display("IRQ GENERATED");

    #50;

    $finish;

end

endmodule
