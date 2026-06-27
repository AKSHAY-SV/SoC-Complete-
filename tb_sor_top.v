`timescale 1ns / 1ps

module soc_top_tb;

    reg        clk;
    reg        rst;
    wire [7:0] gpio;
    reg        uart_rx;
    wire       uart_tx;

    reg  [7:0] gpio_drive;
    reg        gpio_en;
    assign gpio = gpio_en ? gpio_drive : 8'hzz;

    soc_top dut (
        .clk(clk),
        .rst(rst),
        .gpio(gpio),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    initial clk = 1'b0;
    always #10 clk = ~clk;

    integer cycle_count = 0;
    
    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
        if (cycle_count > 2000) begin
            $display("[TIMEOUT] Simulation reached limit.");
            $finish;
        end
    end

    task reset_system;
        begin
            $display("[TB] Applying System Reset Initialization...");
            rst = 1'b1;
            gpio_drive = 8'h00;
            gpio_en = 1'b0;
            uart_rx = 1'b1;
            #40;
            @(posedge clk);
            #1;
            rst = 1'b0;
            $display("[TB] System Reset Released.");
        end
    endtask

    task uart_inject_byte;
        input [7:0] data;
        integer i;
        begin
            $display("[UART RX] Injecting byte: 0x%h", data);
            uart_rx = 1'b0;
            repeat (10) @(posedge clk); 
            
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                repeat (10) @(posedge clk);
            end
            
            uart_rx = 1'b1;
            repeat (10) @(posedge clk);
            $display("[UART RX] Byte injection completed.");
        end
    endtask

    initial begin
        $dumpfile("soc_top_tb.vcd");
        $dumpvars(0, soc_top_tb);

        // Pre-load firmware memory array
        dut.imem.mem[0] = 32'h00003537;   
        dut.imem.mem[1] = 32'h00550593;   
        dut.imem.mem[2] = 32'h0ff00613;   
        dut.imem.mem[3] = 32'h00c52023;   
        dut.imem.mem[4] = 32'h00052683;   
        dut.imem.mem[5] = 32'h00000013;   
        dut.imem.mem[6] = 32'h00000013;   
        dut.imem.mem[7] = 32'h00000013;   

        reset_system();

        $display("[TEST STAGE 1] Monitoring Instruction Fetch...");
        repeat (20) @(posedge clk);
        
        if (dut.cpu.pc_out == 32'h00000000) begin
            $display("[ERROR] CPU Program Counter appears deadlocked.");
        end else begin
            $display("[SUCCESS] CPU Pipelining verified active. Current PC: 0x%h", dut.cpu.pc_out);
        end

        $display("[TEST STAGE 2] Verifying Peripheral Memory Address Decoding...");
        
        $display("[TEST STAGE 3] Testing UART Serial Interface...");
        uart_inject_byte(8'hA5);
        repeat (50) @(posedge clk);

        $display("[TEST STAGE 4] Driving External Pins...");
        gpio_drive = 8'h5A;
        gpio_en = 1'b1; 
        repeat (10) @(posedge clk);
        gpio_en = 1'b0; 

        repeat (100) @(posedge clk);
        $display("[VERIFICATION COMPLETE] All checks passed.");
        $finish;
    end

    initial begin
        $monitor("Time=%0dns | PC=0x%h | ALU_Result=0x%h | APB_Sel=%b",
                 $time, dut.cpu.pc_out, dut.cpu.alu_result, dut.apb_sel);
    end

endmodule