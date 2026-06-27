`timescale 1ns/1ps

module tb_spi_master_apb;

reg pclk;
reg presetn;

reg psel;
reg penable;
reg pwrite;

reg [31:0] paddr;
reg [31:0] pwdata;

wire [31:0] prdata;
wire pready;

wire sclk;
wire mosi;
wire cs_n;

wire irq;

wire miso;

assign miso = mosi;

spi_master_apb DUT (

    .pclk(pclk),
    .presetn(presetn),

    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),

    .prdata(prdata),
    .pready(pready),

    .sclk(sclk),
    .mosi(mosi),
    .miso(miso),
    .cs_n(cs_n),

    .irq(irq)

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

task apb_read;
input [31:0] addr;
begin

    @(posedge pclk);

    psel=1;
    pwrite=0;
    penable=0;

    paddr=addr;

    @(posedge pclk);

    penable=1;

    @(posedge pclk);

    $display("READ Addr=%h Data=%h",
              addr,
              prdata);

    psel=0;
    penable=0;

end
endtask

initial
begin

    $dumpfile("spi.vcd");
    $dumpvars(0,tb_spi_master_apb);

    psel=0;
    penable=0;
    pwrite=0;
    paddr=0;
    pwdata=0;

    presetn=0;

    repeat(5) @(posedge pclk);

    presetn=1;

    //--------------------------------
    // TXDATA = A5
    //--------------------------------

    apb_write(32'h00,32'hA5);

    //--------------------------------
    // START
    //--------------------------------

    apb_write(32'h08,32'h1);

    wait(irq);

    $display("SPI TRANSFER COMPLETE");

    apb_read(32'h04);
    apb_read(32'h0C);

    #50;

    $finish;

end

endmodule
