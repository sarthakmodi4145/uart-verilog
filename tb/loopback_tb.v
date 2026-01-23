module loopback_tb;
    reg clk;
    reg rst;
    reg wr_en;
    reg [7:0] tx_data;
    wire tx_line;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rdy;
    reg rdy_clr;
    wire baud_tick1;
    wire baud_tick2;
    
    // Clock generation: 50 MHz
    always #10 clk = ~clk;  // 20ns period = 50MHz
    
    // Baud Generator
    baud_gen #(
        .clk_freq(50_000_000),  // 50 MHz
        .baud(9600)
    ) baud_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick1(baud_tick1),
        .baud_tick2(baud_tick2)
    );
    
    // UART Transmitter
    transmitter tx_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick1(baud_tick1),
        .wr_en(wr_en),
        .data_in(tx_data),
        .tx(tx_line),
        .busy(tx_busy)
    );
    
    // UART Receiver (loopback)
    receiver rx_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick2(baud_tick2),
        .rx(tx_line),
        .rdy_clr(rdy_clr),
        .data_out(rx_data),
        .rdy(rdy)
    );
    
    // Test data array
    reg [7:0] test_data [0:4];
    integer i;
    
    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, loopback_tb);
        
        // Initialize test data
        test_data[0] = 8'hA5;
        test_data[1] = 8'h5A;
        test_data[2] = 8'hCB;
        test_data[3] = 8'hFF;
        test_data[4] = 8'h00;
        
        // Initialize signals
        clk = 0;
        rst = 1;
        wr_en = 0;
        tx_data = 8'h00;
        rdy_clr = 0;
        
        // Reset period
        #100;
        rst = 0;
        #100;
        
        $display("========================================");
        $display("UART Multiple Byte Test Started");
        $display("========================================\n");
        
        // Send multiple bytes
        for (i = 0; i < 5; i = i + 1) begin
            // Wait for transmitter to be ready
            wait (tx_busy == 1'b0);
            #100;
            
            // Start transmission
            tx_data = test_data[i];
            $display("Time %0t: Sending byte %0d: 0x%h", $time, i, tx_data);
            wr_en = 1;
            #20;
            wr_en = 0;
            
            // Wait for receiver ready signal
            wait (rdy == 1'b1);
            #100;
            
            // Check received data
            $display("Time %0t: Received byte %0d: 0x%h", $time, i, rx_data);
            if (tx_data == rx_data)
                $display("✓ Byte %0d: SUCCESS - Data matches!\n", i);
            else
                $display("✗ Byte %0d: FAIL - Expected: 0x%h, Got: 0x%h\n", i, tx_data, rx_data);
            
            // Clear ready flag
            #20;
            rdy_clr = 1;
            #20;
            rdy_clr = 0;
            
            // Small delay between transmissions
            #1000;
        end
        
        $display("========================================");
        $display("All %0d bytes transmitted successfully!", i);
        $display("========================================");
        
        // Extra time before finish
        #100000;
        $finish;
    end
    
endmodule