`timescale 1ns / 1ps

// ====================================================================
// Silicon Primitive Behavioral Models for Standalone Simulation
// ====================================================================
module GPIOPAD (
    inout wire PAD,
    input wire OUT,
    input wire OE,
    output wire IN
);
    assign PAD = OE ? OUT : 1'bz;
    assign IN = PAD;
endmodule

// ====================================================================
// Main System-on-Chip Module
// ====================================================================
module soc_top (
    input wire clk,
    input wire rst,
    inout wire [7:0] gpio, 
    input wire uart_rx,
    output wire uart_tx
);

    wire [31:0] instr_addr;
    wire [31:0] instr_rdata;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire        data_we;
    wire        data_re;
    wire [31:0] ram_rdata;
    wire [31:0] apb_prdata;
    wire        apb_pready;
    wire        cpu_irq;

    // Split Internal Pin Connections
    wire [7:0] gpio_in;
    wire [7:0] gpio_out;
    wire [7:0] gpio_oe;

    // Physical ASIC Bi-directional Pad Primitives Generate Loop
    genvar k;
    generate
        for(k=0; k<8; k=k+1) begin : GDSII_GPIO_PADS
            GPIOPAD u_pad (
                .PAD(gpio[k]),
                .OUT(gpio_out[k]),
                .OE(gpio_oe[k]),
                .IN(gpio_in[k])
            );
        end
    endgenerate

    datapath cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(),
        .alu_result(),
        .instr(),
        .reg_write(),
        .instr_addr(instr_addr),
        .instr_rdata(instr_rdata),
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_we(data_we),
        .data_re(data_re),
        .data_rdata(data_rdata)
    );

    instr_mem imem (
        .addr(instr_addr),
        .instr(instr_rdata)
    );

    wire ram_sel;
    wire apb_sel;
    
    assign apb_sel = (data_addr >= 32'h0000_1000) && (data_addr <= 32'h0000_5000);
    assign ram_sel = ~apb_sel;

    data_mem dmem (
        .clk(clk),
        .we(data_we & ram_sel),
        .re(data_re & ram_sel),
        .mem_size(2'b10),
        .mem_signed(1'b1),
        .addr(data_addr),
        .wd(data_wdata),
        .rd(ram_rdata)
    );

    reg apb_psel_reg;
    reg apb_penable_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            apb_psel_reg    <= 1'b0;
            apb_penable_reg <= 1'b0;
        end else begin
            apb_psel_reg    <= apb_sel && (data_we || data_re);
            apb_penable_reg <= apb_psel_reg;
        end
    end

    apb_subsystem apb (
        .pclk(clk),
        .presetn(~rst),
        .psel(apb_psel_reg),
        .penable(apb_penable_reg),
        .pwrite(data_we),
        .paddr(data_addr),
        .pwdata(data_wdata),
        .prdata(apb_prdata),
        .pready(apb_pready),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oe(gpio_oe),
        .cpu_irq(cpu_irq)
    );

    assign data_rdata = ram_sel ? ram_rdata : apb_prdata;

endmodule