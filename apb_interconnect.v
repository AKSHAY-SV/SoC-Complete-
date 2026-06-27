`timescale 1ns / 1ps

module apb_interconnect (
    input wire           psel,
    input wire           penable,
    input wire           pwrite,
    input wire  [31:0]   paddr,
    input wire  [31:0]   pwdata,
    output wire [31:0]   prdata,
    output wire          pready,

    // UART
    output wire          uart_psel,
    output wire          uart_penable,
    output wire          uart_pwrite,
    output wire [31:0]   uart_paddr,
    output wire [31:0]   uart_pwdata,
    input wire  [31:0]   uart_prdata,
    input wire           uart_pready,

    // GPIO
    output wire          gpio_psel,
    output wire          gpio_penable,
    output wire          gpio_pwrite,
    output wire [31:0]   gpio_paddr,
    output wire [31:0]   gpio_pwdata,
    input wire  [31:0]   gpio_prdata,
    input wire           gpio_pready,

    // TIMER
    output wire          timer_psel,
    output wire          timer_penable,
    output wire          timer_pwrite,
    output wire [31:0]   timer_paddr,
    output wire [31:0]   timer_pwdata,
    input wire  [31:0]   timer_prdata,
    input wire           timer_pready,

    // SPI
    output wire          spi_psel,
    output wire          spi_penable,
    output wire          spi_pwrite,
    output wire [31:0]   spi_paddr,
    output wire [31:0]   spi_pwdata,
    input wire  [31:0]   spi_prdata,
    input wire           spi_pready,

    // PLIC
    output wire          plic_psel,
    output wire          plic_penable,
    output wire          plic_pwrite,
    output wire [31:0]   plic_paddr,
    output wire [31:0]   plic_pwdata,
    input wire  [31:0]   plic_prdata,
    input wire           plic_pready
);

    // Explicit and Non-overlapping Peripheral Base Offsets
    wire sel_gpio  = (paddr[31:12] == 20'h0000_1); // Base 0x1000
    wire sel_timer = (paddr[31:12] == 20'h0000_2); // Base 0x2000
    wire sel_spi   = (paddr[31:12] == 20'h0000_3); // Base 0x3000
    wire sel_plic  = (paddr[31:12] == 20'h0000_4); // Base 0x4000
    wire sel_uart  = (paddr[31:12] == 20'h0000_5); // Base 0x5000

    // Gated Control Outputs
    assign gpio_psel    = psel & sel_gpio;
    assign gpio_penable = penable & sel_gpio;
    assign gpio_pwrite  = pwrite;
    assign gpio_paddr   = paddr;
    assign gpio_pwdata  = pwdata;

    assign timer_psel    = psel & sel_timer;
    assign timer_penable = penable & sel_timer;
    assign timer_pwrite  = pwrite;
    assign timer_paddr   = paddr;
    assign timer_pwdata  = pwdata;

    assign spi_psel    = psel & sel_spi;
    assign spi_penable = penable & sel_spi;
    assign spi_pwrite  = pwrite;
    assign spi_paddr   = paddr;
    assign spi_pwdata  = pwdata;

    assign plic_psel    = psel & sel_plic;
    assign plic_penable = penable & sel_plic;
    assign plic_pwrite  = pwrite;
    assign plic_paddr   = paddr;
    assign plic_pwdata  = pwdata;

    assign uart_psel    = psel & sel_uart;
    assign uart_penable = penable & sel_uart;
    assign uart_pwrite  = pwrite;
    assign uart_paddr   = paddr;
    assign uart_pwdata  = pwdata;

    // Unified System Bus Response Feedback Loops
    assign pready = sel_gpio  ? gpio_pready  :
                    sel_timer ? timer_pready :
                    sel_spi   ? spi_pready   :
                    sel_plic  ? plic_pready  :
                    sel_uart  ? uart_pready  : 1'b1;

    assign prdata = sel_gpio  ? gpio_prdata  :
                    sel_timer ? timer_prdata :
                    sel_spi   ? spi_prdata   :
                    sel_plic  ? plic_prdata  :
                    sel_uart  ? uart_prdata  : 32'hDEADBEEF;

endmodule