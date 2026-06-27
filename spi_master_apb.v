module spi_master_apb (

    input           pclk,
    input           presetn,

    input           psel,
    input           penable,
    input           pwrite,
    input  [31:0]   paddr,
    input  [31:0]   pwdata,

    output reg [31:0] prdata,
    output          pready,

    output reg      sclk,
    output          mosi,
    input           miso,
    output reg      cs_n,

    output          irq

);

reg [7:0] txdata_reg;
reg [7:0] rxdata_reg;
reg [31:0] control_reg;
reg [31:0] status_reg;

reg [7:0] shift_tx;
reg [7:0] shift_rx;

reg [3:0] bit_count;
reg busy;

assign pready = 1'b1;

assign irq = status_reg[1];

assign mosi = shift_tx[7];

wire apb_write;
wire apb_read;

assign apb_write = psel & penable & pwrite;
assign apb_read  = psel & penable & ~pwrite;

always @(posedge pclk or negedge presetn)
begin

    if(!presetn)
    begin

        txdata_reg  <= 0;
        rxdata_reg  <= 0;
        control_reg <= 0;
        status_reg  <= 0;

        shift_tx <= 0;
        shift_rx <= 0;

        bit_count <= 0;

        busy <= 0;

        sclk <= 0;
        cs_n <= 1;

    end

    else
    begin

        //-----------------------------------
        // APB WRITE
        //-----------------------------------

        if(apb_write)
        begin

            case(paddr[7:0])

                8'h00:
                    txdata_reg <= pwdata[7:0];

                8'h08:
                begin

                    control_reg <= pwdata;

                    if(pwdata[0] && !busy)
                    begin

                        shift_tx <= txdata_reg;
                        shift_rx <= 8'h00;

                        bit_count <= 8;

                        busy <= 1;

                        status_reg[0] <= 1;
                        status_reg[1] <= 0;

                        cs_n <= 0;

                    end

                end

            endcase

        end

        //-----------------------------------
        // SPI SHIFT ENGINE
        //-----------------------------------

        if(busy)
        begin

            sclk <= ~sclk;

            if(sclk == 0)
            begin

                shift_rx <= {shift_rx[6:0], miso};
                shift_tx <= {shift_tx[6:0], 1'b0};

                bit_count <= bit_count - 1;

                if(bit_count == 1)
                begin

                    busy <= 0;

                    cs_n <= 1;

                    rxdata_reg <= {shift_rx[6:0], miso};

                    status_reg[0] <= 0;
                    status_reg[1] <= 1;

                end

            end

        end

    end

end

always @(*)
begin

    prdata = 32'h0;

    if(apb_read)
    begin

        case(paddr[7:0])

            8'h00: prdata = {24'd0, txdata_reg};
            8'h04: prdata = {24'd0, rxdata_reg};
            8'h08: prdata = control_reg;
            8'h0C: prdata = status_reg;

            default:
                prdata = 32'hDEADBEEF;

        endcase

    end

end

endmodule
