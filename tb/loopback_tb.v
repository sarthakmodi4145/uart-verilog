module loopback_tb;
    reg clk;
    reg rst;
    reg wr_en;
    reg [7:0] tx_data;
    wire tx_line;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rdy;
    wire parity_error;
    reg rdy_clr;
    
    
    reg [7:0] test_data [0:4];
    integer i;
    
    
    always #10 clk = ~clk;
    
    
    uart_top #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(9600),
        .PARITY_EN(1),          
        .PARITY_TYPE(0)         
    ) uart_system (
        .clk(clk),
        .rst(rst),
        .tx_data_in(tx_data),
        .tx_wr_en(wr_en),
        .tx_out(tx_line),
        .tx_busy_out(tx_busy),
        .rx_in(tx_line),
        .rx_rdy_clr(rdy_clr),
        .rx_data_out(rx_data),
        .rx_rdy_out(rdy),
        .rx_parity_error(parity_error)
    );
    
    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, loopback_tb);
        
       
        test_data[0] = 8'hA5;
        test_data[1] = 8'h5A;
        test_data[2] = 8'hCB;
        test_data[3] = 8'hFF;
        test_data[4] = 8'h00;
        
        clk = 0;
        rst = 1;
        wr_en = 0;
        tx_data = 8'h00;
        rdy_clr = 0;
        
        #100;
        rst = 0;
        #100;
        
       
       
        $display("Parity: EVEN, Clock: 50MHz, Baud: 9600");
        
        
        for (i = 0; i < 5; i = i + 1) begin
            wait (tx_busy == 1'b0);
            #100;
            
            tx_data = test_data[i];
            $display("Time %0t: Sending byte %0d: 0x%h", $time, i, tx_data);
            wr_en = 1;
            #20;
            wr_en = 0;
            
            wait (rdy == 1'b1);
            #100;
            
            $display("Time %0t: Received byte %0d: 0x%h", $time, i, rx_data);
            
            if (parity_error)
                $display("✗ Byte %0d: PARITY ERROR!\n", i);
            else if (tx_data == rx_data)
                $display("✓ Byte %0d: SUCCESS - Data matches, No parity error\n", i);
            else
                $display("✗ Byte %0d: FAIL - Data mismatch\n", i);
            
            #20;
            rdy_clr = 1;
            #20;
            rdy_clr = 0;
            #1000;
        end
        
       
        $display("Test Completed!");
        
        
        #100000;
        $finish;
    end
    
endmodule