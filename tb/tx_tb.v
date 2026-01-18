module tx_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg [7:0] data_in;
    wire baud_tick;
    wire tx;
    wire busy;

    // Instantiate baud generator
    baud_gen #(
        .clk_freq(1_000_000), // lower for fast sim
        .baud(9600)
    ) baud_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // Instantiate transmitter
    transmitter tx_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .wr_en(wr_en),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    // Clock: 1 MHz
    always #5 clk = ~clk;

    initial begin
    $dumpfile("tx.vcd");
    $dumpvars(0, tx_tb);  // or tx_tb if that is your module name
        clk = 0;
        rst = 1;
        wr_en = 0;
        data_in = 8'h00;

        #50;
        rst = 0;

        #50;
        data_in = 8'hA5; // 10100101
        wr_en = 1;

        #10;
        wr_en = 0;

        #200000; // wait long enough
        $finish;
    end

endmodule