module apb_interconnect (

    input           psel,
    input           penable,
    input           pwrite,
    input  [31:0]   paddr,
    input  [31:0]   pwdata,

    output [31:0]   prdata,
    output          pready,

    // GPIO Slave
    output          gpio_psel,
    output          gpio_penable,
    output          gpio_pwrite,
    output [31:0]   gpio_paddr,
    output [31:0]   gpio_pwdata,

    input  [31:0]   gpio_prdata,
    input           gpio_pready,

    // TIMER Slave
    output          timer_psel,
    output          timer_penable,
    output          timer_pwrite,
    output [31:0]   timer_paddr,
    output [31:0]   timer_pwdata,

    input  [31:0]   timer_prdata,
    input           timer_pready,

    // SPI Slave
    output          spi_psel,
    output          spi_penable,
    output          spi_pwrite,
    output [31:0]   spi_paddr,
    output [31:0]   spi_pwdata,

    input  [31:0]   spi_prdata,
    input           spi_pready,

    // PLIC Slave
    output          plic_psel,
    output          plic_penable,
    output          plic_pwrite,
    output [31:0]   plic_paddr,
    output [31:0]   plic_pwdata,

    input  [31:0]   plic_prdata,
    input           plic_pready
);

wire sel_gpio;
wire sel_timer;
wire sel_spi;
wire sel_plic;

assign sel_gpio  = (paddr[15:12] == 4'h0);
assign sel_timer = (paddr[15:12] == 4'h1);

assign gpio_psel    = psel & sel_gpio;
assign gpio_penable = penable;
assign gpio_pwrite  = pwrite;
assign gpio_paddr   = paddr;
assign gpio_pwdata  = pwdata;

assign timer_psel    = psel & sel_timer;
assign timer_penable = penable;
assign timer_pwrite  = pwrite;
assign timer_paddr   = paddr;
assign timer_pwdata  = pwdata;

assign prdata =
       sel_gpio ? gpio_prdata :
       sel_timer ? timer_prdata :
       sel_spi ? spi_prdata :
       sel_plic ? plic_prdata :
       32'hDEADBEEF;

assign pready =
       sel_gpio ? gpio_pready :
       sel_timer ? timer_pready :
       sel_spi ? spi_pready :
       sel_plic ? plic_pready :
       1'b1;

assign sel_spi  = (paddr[15:12] == 4'h2);
assign sel_plic = (paddr[15:12] == 4'h3);

assign spi_psel    = psel & sel_spi;
assign spi_penable = penable;
assign spi_pwrite  = pwrite;
assign spi_paddr   = paddr;
assign spi_pwdata  = pwdata;

assign plic_psel    = psel & sel_plic;
assign plic_penable = penable;
assign plic_pwrite  = pwrite;
assign plic_paddr   = paddr;
assign plic_pwdata  = pwdata;



endmodule
