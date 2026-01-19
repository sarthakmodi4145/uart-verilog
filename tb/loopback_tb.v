module loopback_tb;

    reg clk;
    reg rst;

    // TX signals
    reg wr_en;
    reg [7:0] tx_data;
    wire tx_line;
    wire tx_busy;

    // RX signals
    wire [7:0] rx_data;
    wire rdy;
    reg rdy_clr;

    // Baud tick
    wire baud_tick1;
    wire baud_tick2;

    // Clock generation: 1 MHz (for fast sim)
    always #5 clk = ~clk;

    // Baud Generator
    baud_gen #(
        .clk_freq(1_000_000),
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
        .rx(tx_line),      // LOOPBACK HERE
        .rdy_clr(rdy_clr),
        .data_out(rx_data),
        .rdy(rdy)
    );

    initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, loopback_tb);
        // Initial values
        clk = 0;
        rst = 1;
        wr_en = 0;
        tx_data = 8'h00;
        rdy_clr = 0;

        // Reset
        #50;
        rst = 0;

        // Send data
        #50;
        tx_data = 8'hA5;   // test byte
        wr_en = 1;

        #10;
        wr_en = 0;

        // Wait for RX to complete
        wait (rdy == 1'b1);

        $display("TX sent     : %h", tx_data);
        $display("RX received : %h", rx_data);

        // Clear ready
        rdy_clr = 1;
        #10;
        rdy_clr = 0;

        #2000000;
        $finish;
    end

endmodule