`timescale 1ns / 1ps

module gpio_apb (
    input wire           pclk,
    input wire           presetn,
    input wire           psel,
    input wire           penable,
    input wire           pwrite,
    input wire  [31:0]   paddr,
    input wire  [31:0]   pwdata,
    output reg  [31:0]   prdata,
    output wire          pready,

    // GDSII Compliant Split Pad Interface (Replaces problematic inout blocks)
    input  wire [7:0]    gpio_in,
    output reg  [7:0]    gpio_out,
    output reg  [7:0]    gpio_oe
);

    reg [7:0] data_reg;
    reg [7:0] dir_reg;

    assign pready = 1'b1;

    // Registers map directly into output lines, avoiding internal high-impedance (1'bz) nodes
    always @(*) begin
        gpio_out = data_reg;
        gpio_oe  = dir_reg;
    end

    wire apb_write = psel & penable & pwrite;
    wire apb_read  = psel & penable & ~pwrite;

    always @(posedge pclk or negedge presetn) begin
        if(!presetn) begin
            data_reg <= 8'h00;
            dir_reg  <= 8'h00;
        end else if(apb_write) begin
            case(paddr[7:0])
                8'h00: data_reg <= pwdata[7:0];
                8'h04: dir_reg  <= pwdata[7:0];
                default: ;
            endcase
        end
    end

    always @(*) begin
        prdata = 32'h00000000;
        if(apb_read) begin
            case(paddr[7:0])
                8'h00: prdata = {24'd0, gpio_in}; // Reads values directly from physical input frame buffers
                8'h04: prdata = {24'd0, dir_reg};
                default: prdata = 32'hDEADBEEF;
            endcase
        end
    end

endmodule