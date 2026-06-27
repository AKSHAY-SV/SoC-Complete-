`timescale 1ns/1ps

module tb_axi_decoder;

reg [31:0] addr;

wire rom_sel;
wire ram_sel;
wire apb_sel;

axi_decoder DUT(

    .addr(addr),

    .rom_sel(rom_sel),
    .ram_sel(ram_sel),
    .apb_sel(apb_sel)

);

initial begin

    $dumpfile("axi_decoder.vcd");
    $dumpvars(0,tb_axi_decoder);

    //--------------------------------
    // ROM
    //--------------------------------

    addr = 32'h0000_1000;

    #10;

    $display("ROM=%b RAM=%b APB=%b",
             rom_sel,
             ram_sel,
             apb_sel);

    //--------------------------------
    // RAM
    //--------------------------------

    addr = 32'h1000_0000;

    #10;

    $display("ROM=%b RAM=%b APB=%b",
             rom_sel,
             ram_sel,
             apb_sel);

    //--------------------------------
    // APB
    //--------------------------------

    addr = 32'h4000_0000;

    #10;

    $display("ROM=%b RAM=%b APB=%b",
             rom_sel,
             ram_sel,
             apb_sel);

    #20;

    $finish;

end

endmodule
