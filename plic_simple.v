module plic_simple (

    input           pclk,
    input           presetn,

    // APB Interface
    input           psel,
    input           penable,
    input           pwrite,
    input  [31:0]   paddr,
    input  [31:0]   pwdata,

    output reg [31:0] prdata,
    output          pready,

    // Interrupt Sources
    input           timer_irq,
    input           spi_irq,
    input           gpio_irq,
    input           uart_irq,

    // CPU Interrupt
    output          cpu_irq

);

reg [3:0] pending_reg;
reg [3:0] enable_reg;

assign pready = 1'b1;

wire apb_write;
wire apb_read;

assign apb_write = psel & penable & pwrite;
assign apb_read  = psel & penable & (~pwrite);

assign cpu_irq = |(pending_reg & enable_reg);

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
    begin
        pending_reg <= 4'b0000;
        enable_reg  <= 4'b0000;
    end
    else
    begin

        //----------------------------------
        // Capture Interrupt Sources
        //----------------------------------

        if(timer_irq)
            pending_reg[0] <= 1'b1;

        if(spi_irq)
            pending_reg[1] <= 1'b1;

        if(gpio_irq)
            pending_reg[2] <= 1'b1;

        if(uart_irq)
            pending_reg[3] <= 1'b1;

        //----------------------------------
        // APB Writes
        //----------------------------------

        if(apb_write)
        begin

            case(paddr[7:0])

                // ENABLE REGISTER
                8'h04:
                    enable_reg <= pwdata[3:0];

                // CLEAR PENDING BITS
                8'h00:
                    pending_reg <= pending_reg & ~pwdata[3:0];

            endcase

        end

    end
end

always @(*)
begin

    prdata = 32'h00000000;

    if(apb_read)
    begin

        case(paddr[7:0])

            8'h00:
                prdata = {28'd0,pending_reg};

            8'h04:
                prdata = {28'd0,enable_reg};

            default:
                prdata = 32'hDEADBEEF;

        endcase

    end

end

endmodule
