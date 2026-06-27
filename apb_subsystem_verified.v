module apb_subsystem(

    input pclk,
    input presetn,

    input psel,
    input penable,
    input pwrite,
    input [31:0] paddr,
    input [31:0] pwdata,

    output [31:0] prdata,
    output pready,

    inout [7:0] gpio,

    output cpu_irq

);

wire gpio_psel;
wire gpio_penable;
wire gpio_pwrite;
wire [31:0] gpio_paddr;
wire [31:0] gpio_pwdata;
wire [31:0] gpio_prdata;
wire gpio_pready;

wire timer_psel;
wire timer_penable;
wire timer_pwrite;
wire [31:0] timer_paddr;
wire [31:0] timer_pwdata;
wire [31:0] timer_prdata;
wire timer_pready;

wire spi_psel;
wire spi_penable;
wire spi_pwrite;

wire [31:0] spi_paddr;
wire [31:0] spi_pwdata;
wire [31:0] spi_prdata;

wire spi_pready;
wire spi_irq;

wire spi_sclk;
wire spi_mosi;
wire spi_cs_n;
wire spi_miso;

wire plic_psel;
wire plic_penable;
wire plic_pwrite;

wire [31:0] plic_paddr;
wire [31:0] plic_pwdata;
wire [31:0] plic_prdata;

wire plic_pready;

wire timer_irq;
wire gpio_irq;
wire uart_irq;

assign gpio_irq = 1'b0;
assign uart_irq = 1'b0;

// loopback for now
assign spi_miso = spi_mosi;

apb_interconnect interconnect (

    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),

    .prdata(prdata),
    .pready(pready),

    .gpio_psel(gpio_psel),
    .gpio_penable(gpio_penable),
    .gpio_pwrite(gpio_pwrite),
    .gpio_paddr(gpio_paddr),
    .gpio_pwdata(gpio_pwdata),
    .gpio_prdata(gpio_prdata),
    .gpio_pready(gpio_pready),

    .timer_psel(timer_psel),
    .timer_penable(timer_penable),
    .timer_pwrite(timer_pwrite),
    .timer_paddr(timer_paddr),
    .timer_pwdata(timer_pwdata),
    .timer_prdata(timer_prdata),
    .timer_pready(timer_pready),

.spi_psel(spi_psel),
.spi_penable(spi_penable),
.spi_pwrite(spi_pwrite),
.spi_paddr(spi_paddr),
.spi_pwdata(spi_pwdata),
.spi_prdata(spi_prdata),
.spi_pready(spi_pready),

.plic_psel(plic_psel),
.plic_penable(plic_penable),
.plic_pwrite(plic_pwrite),
.plic_paddr(plic_paddr),
.plic_pwdata(plic_pwdata),
.plic_prdata(plic_prdata),
.plic_pready(plic_pready)
);

gpio_apb gpio_inst (

    .pclk(pclk),
    .presetn(presetn),

    .psel(gpio_psel),
    .penable(gpio_penable),
    .pwrite(gpio_pwrite),
    .paddr(gpio_paddr),
    .pwdata(gpio_pwdata),

    .prdata(gpio_prdata),
    .pready(gpio_pready),

    .gpio(gpio)
);

timer_apb timer_inst (

    .pclk(pclk),
    .presetn(presetn),

    .psel(timer_psel),
    .penable(timer_penable),
    .pwrite(timer_pwrite),
    .paddr(timer_paddr),
    .pwdata(timer_pwdata),

    .prdata(timer_prdata),
    .pready(timer_pready),

    .irq(timer_irq)
);

spi_master_apb spi_inst (

    .pclk(pclk),
    .presetn(presetn),

    .psel(spi_psel),
    .penable(spi_penable),
    .pwrite(spi_pwrite),
    .paddr(spi_paddr),
    .pwdata(spi_pwdata),

    .prdata(spi_prdata),
    .pready(spi_pready),

    .sclk(spi_sclk),
    .mosi(spi_mosi),
    .miso(spi_miso),
    .cs_n(spi_cs_n),

    .irq(spi_irq)

);


plic_simple plic_inst (

    .pclk(pclk),
    .presetn(presetn),

    .psel(plic_psel),
    .penable(plic_penable),
    .pwrite(plic_pwrite),
    .paddr(plic_paddr),
    .pwdata(plic_pwdata),

    .prdata(plic_prdata),
    .pready(plic_pready),

    .timer_irq(timer_irq),
    .spi_irq(spi_irq),
    .gpio_irq(gpio_irq),
    .uart_irq(uart_irq),

    .cpu_irq(cpu_irq)

);

endmodule

