`timescale 1ns / 1ps

module timer_apb (
    input wire           pclk,
    input wire           presetn,
    input wire           psel,
    input wire           penable,
    input wire           pwrite,
    input wire  [31:0]   paddr,
    input wire  [31:0]   pwdata,
    output reg  [31:0]   prdata,
    output wire          pready,
    output wire          irq
);

    reg [31:0] load_reg;
    reg [31:0] value_reg;
    reg [31:0] control_reg;
    reg [31:0] irq_status_reg;

    assign pready = 1'b1;
    assign irq    = irq_status_reg[0];

    wire apb_write = psel & penable & pwrite;
    wire apb_read  = psel & penable & ~pwrite;

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            load_reg       <= 32'd0;
            value_reg      <= 32'd0;
            control_reg    <= 32'd0;
            irq_status_reg <= 32'd0;
        end else begin
            // Clear Interrupt Status Register via Register Write Address
            if (apb_write && (paddr[7:0] == 8'h0C)) begin
                irq_status_reg <= 32'd0;
            end

            if (apb_write) begin
                case (paddr[7:0])
                    8'h00: begin
                        load_reg  <= pwdata;
                        value_reg <= pwdata;
                    end
                    8'h08: begin
                        control_reg <= pwdata;
                    end
                    default: ;
                endcase
            end else if (control_reg[0]) begin
                if (value_reg > 0) begin
                    value_reg <= value_reg - 1;
                end else begin
                    irq_status_reg[0] <= 1'b1;
                    if (control_reg[1]) begin
                        value_reg <= load_reg;
                    end else begin
                        control_reg[0] <= 1'b0; // Clean, synchronized state termination
                    end
                end
            end
        end
    end

    always @(*) begin
        prdata = 32'd0;
        if (apb_read) begin
            case (paddr[7:0])
                8'h00:   prdata = load_reg;
                8'h04:   prdata = value_reg;
                8'h08:   prdata = control_reg;
                8'h0C:   prdata = irq_status_reg;
                default: prdata = 32'hDEADBEEF;
            endcase
        end
    end

endmodule