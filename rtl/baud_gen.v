
module baud_gen(
    input wire clk, 
    input wire rst,
    output reg baud_tick1,
    output reg baud_tick2
);
    parameter clk_freq = 50_000_000;
    parameter baud = 9600;
    
    localparam integer baud_div1 = clk_freq / baud;
    localparam integer baud_div2 = clk_freq / (baud * 16);
    
    reg [$clog2(baud_div1)-1:0] counter1;
    reg [$clog2(baud_div2)-1:0] counter2;

    // Baud tick generator
    always @(posedge clk) begin
        if (rst) begin
            counter1 <= 0;
            baud_tick1 <= 1'b0;
        end else begin
            if (counter1 == baud_div1 - 1) begin
                counter1 <= 0;
                baud_tick1 <= 1'b1;
            end else begin
                counter1 <= counter1 + 1;
                baud_tick1 <= 1'b0;
            end
        end
    end

    // Oversample tick generator  
    always @(posedge clk) begin
        if (rst) begin
            counter2 <= 0;
            baud_tick2 <= 1'b0;
        end else begin
            if (counter2 == baud_div2 - 1) begin
                counter2 <= 0;
                baud_tick2 <= 1'b1;
            end else begin
                counter2 <= counter2 + 1;
                baud_tick2 <= 1'b0;
            end
        end
    end
endmodule