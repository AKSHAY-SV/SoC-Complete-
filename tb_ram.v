`timescale 1ns/1ps

module tb_ram;

reg clk;

reg we;
reg [31:0] addr;
reg [31:0] wdata;

wire [31:0] rdata;

ram DUT(
    .clk(clk),
    .we(we),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $dumpfile("ram.vcd");
    $dumpvars(0,tb_ram);

    we    = 0;
    addr  = 0;
    wdata = 0;

    //--------------------------------
    // Write Address 0
    //--------------------------------

    @(posedge clk);

    we    = 1;
    addr  = 32'h00000000;
    wdata = 32'hDEADBEEF;

    @(posedge clk);

    //--------------------------------
    // Write Address 4
    //--------------------------------

    addr  = 32'h00000004;
    wdata = 32'h12345678;

    @(posedge clk);

    we = 0;

    //--------------------------------
    // Read Address 0
    //--------------------------------

    addr = 32'h00000000;

    @(posedge clk);

    $display("ADDR=%h DATA=%h",addr,rdata);

    //--------------------------------
    // Read Address 4
    //--------------------------------

    addr = 32'h00000004;

    @(posedge clk);

    $display("ADDR=%h DATA=%h",addr,rdata);

    #20;

    $finish;

end

endmodule
