`timescale 1ns/1ps

// Simulation wrapper for Clock Tree Buffer Primitive
module CLKBUF (
    input wire A,
    output wire X
);
    assign X = A;
endmodule

module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc_out
);

    wire clk_buffered;

    CLKBUF u_clk_buf (
        .A(clk),
        .X(clk_buffered)
    );

    always @(posedge clk_buffered or posedge rst) begin
        if (rst)
            pc_out <= 32'h00000000;
        else
            pc_out <= pc_next;
    end
endmodule