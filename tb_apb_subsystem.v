`timescale 1ns/1ps

module tb_apb_subsystem;

reg pclk;
reg presetn;

reg psel;
reg penable;
reg pwrite;

reg [31:0] paddr;
reg [31:0] pwdata;

wire [31:0] prdata;
wire pready;

wire cpu_irq;
wire [7:0] gpio;

apb_subsystem DUT (

    .pclk(pclk),
    .presetn(presetn),

    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),

    .prdata(prdata),
    .pready(pready),

    .gpio(gpio),

    .cpu_irq(cpu_irq)

);


//--------------------------------------------------
// Clock
//--------------------------------------------------

initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
end


//--------------------------------------------------
// APB Write Task
//--------------------------------------------------

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


//--------------------------------------------------
// APB Read Task
//--------------------------------------------------

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

    $display("READ  Addr=%h Data=%h",
              addr,
              prdata);

    psel    = 0;
    penable = 0;

end
endtask


//--------------------------------------------------
// Main Test
//--------------------------------------------------

initial begin

    $dumpfile("apb_subsystem.vcd");
    $dumpvars(0,tb_apb_subsystem);

    psel    = 0;
    penable = 0;
    pwrite  = 0;

    paddr   = 0;
    pwdata  = 0;

    presetn = 0;

    repeat(5) @(posedge pclk);

    presetn = 1;

    //--------------------------------------------------
    // GPIO TEST
    //--------------------------------------------------

    $display("\n========================");
    $display("GPIO TEST");
    $display("========================");

    // DIR = FF
    apb_write(32'h0000_0004,32'h000000FF);

    // DATA = A5
    apb_write(32'h0000_0000,32'h000000A5);

    apb_read(32'h0000_0004);

    apb_read(32'h0000_0000);

    if(gpio == 8'hA5)
        $display("GPIO PASS");
    else
        $display("GPIO FAIL");


    //--------------------------------------------------
    // TIMER TEST
    //--------------------------------------------------

    $display("\n========================");
    $display("TIMER TEST");
    $display("========================");

    // LOAD = 10
    apb_write(32'h0000_1000,32'd10);

    // CONTROL = 1
    apb_write(32'h0000_1008,32'h1);

    wait(cpu_irq);

    $display("TIMER IRQ GENERATED");

    apb_read(32'h0000_1000);
    apb_read(32'h0000_1004);
    apb_read(32'h0000_1008);
    apb_read(32'h0000_100C);

    $display("\n========================");
    $display("APB SUBSYSTEM PASS");
    $display("========================");

    #50;

    $finish;

end

endmodule
