`timescale 1ns / 1ps

module uart_fifo(

    input wire clk,
    input wire rst,

    input wire wr_en,
    input wire rd_en,

    input wire [7:0] din,

    output reg [7:0] dout,

    output wire full,
    output wire empty

);

reg [7:0] mem [0:15];

reg [3:0] wr_ptr;
reg [3:0] rd_ptr;

reg [4:0] count;

assign full  = (count == 16);
assign empty = (count == 0);

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        wr_ptr <= 0;
        rd_ptr <= 0;
        count  <= 0;
        dout   <= 0;

end
else
begin

    case ({wr_en && !full, rd_en && !empty})

    2'b10:
    begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1'b1;
        count <= count + 1'b1;
    end

    2'b01:
    begin
        dout <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1'b1;
        count <= count - 1'b1;
    end

    2'b11:
    begin
        mem[wr_ptr] <= din;
        dout <= mem[rd_ptr];

        wr_ptr <= wr_ptr + 1'b1;
        rd_ptr <= rd_ptr + 1'b1;

        count <= count;
    end

    default:
    begin
        count <= count;
    end

    endcase
end
end
endmodule
    
