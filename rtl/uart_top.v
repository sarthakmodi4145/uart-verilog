module uart_top #(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire rst,
    // Transmitter interface
    input wire [7:0] tx_data,
    input wire tx_start,
    output wire tx,
    output wire tx_busy,
    // Receiver interface
    input wire rx,
    output wire [7:0] rx_data,
    output wire rx_ready
);
    wire baud_tick;
    wire oversample_tick;
    
    baudrate_generator #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .oversample_tick(oversample_tick)
    );
    
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );
    
    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .oversample_tick(oversample_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );
endmodule