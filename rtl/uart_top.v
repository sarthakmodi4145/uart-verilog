module uart_top #(
    parameter CLK_FREQ = 50_000_000,  
    parameter BAUD_RATE = 9600,       
    parameter PARITY_EN = 1,          
    parameter PARITY_TYPE = 0         
)(
    input  wire clk,
    input  wire rst,
    
    // Transmitter interface
    input  wire [7:0] tx_data_in,
    input  wire tx_wr_en,
    output wire tx_out,
    output wire tx_busy_out,
    
    
    input  wire rx_in,
    input  wire rx_rdy_clr,
    output wire [7:0] rx_data_out,
    output wire rx_rdy_out,
    output wire rx_parity_error
);

    
    wire baud_tick1;
    wire baud_tick2;
    
    
    // Baud Rate Generator Instance
   
    baud_gen #(
        .clk_freq(CLK_FREQ),
        .baud(BAUD_RATE)
    ) baud_generator (
        .clk(clk),
        .rst(rst),
        .baud_tick1(baud_tick1),
        .baud_tick2(baud_tick2)
    );
    
   
    // UART Transmitter Instance
    
    transmitter #(
        .PARITY_EN(PARITY_EN),
        .PARITY_TYPE(PARITY_TYPE)
    ) uart_transmitter (
        .clk(clk),
        .rst(rst),
        .baud_tick1(baud_tick1),
        .wr_en(tx_wr_en),
        .data_in(tx_data_in),
        .tx(tx_out),
        .busy(tx_busy_out)
    );
    
    
    // UART Receiver Instance
    
    receiver #(
        .PARITY_EN(PARITY_EN),
        .PARITY_TYPE(PARITY_TYPE)
    ) uart_receiver (
        .clk(clk),
        .rst(rst),
        .baud_tick2(baud_tick2),
        .rx(rx_in),
        .rdy_clr(rx_rdy_clr),
        .data_out(rx_data_out),
        .rdy(rx_rdy_out),
        .parity_error(rx_parity_error)
    );

endmodule