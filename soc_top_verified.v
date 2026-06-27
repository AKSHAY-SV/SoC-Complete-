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

wire data_we;
wire data_re;

wire [31:0] ram_rdata;

wire [31:0] apb_prdata;
wire apb_pready;

wire cpu_irq;

//----------------------------------
// CPU
//----------------------------------

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

//----------------------------------
// Instruction Memory
//----------------------------------

instr_mem imem (

    .addr(instr_addr),
    .instr(instr_rdata)

);

//----------------------------------
// Address Decode
//----------------------------------

wire ram_sel;
wire apb_sel;

// APB peripherals occupy 0x1000 - 0x3FFF
assign apb_sel =
       (data_addr >= 32'h0000_1000) &&
       (data_addr <  32'h0000_5000);

// Everything else goes to RAM
assign ram_sel = ~apb_sel;


//----------------------------------
// RAM
//----------------------------------

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

//----------------------------------
// APB Subsystem
//----------------------------------

apb_subsystem apb (

    .pclk(clk),
    .presetn(~rst),

    .psel(apb_sel),
    .penable(apb_sel),

    .pwrite(data_we),

    .paddr(data_addr),
    .pwdata(data_wdata),

    .prdata(apb_prdata),
    .pready(apb_pready),

    .gpio(gpio),

    .cpu_irq(cpu_irq)

);

//----------------------------------
// Read Data Mux
//----------------------------------

assign data_rdata =
        ram_sel ? ram_rdata :
                  apb_prdata;

endmodule
