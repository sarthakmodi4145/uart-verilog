module baud_gen(input wire clk, input wire rst,output reg baud_tick);
parameter clk_freq=50_000_000;
parameter baud=9600;
localparam integer baud_div=clk_freq/baud ;
reg [$clog2(baud_div)-1:0] counter;

always @(posedge clk) begin
    if (rst) begin
        counter<=0;
        baud_tick<=1'b0;
    end

    else if (counter==baud_div-1)begin
        counter<=0;
        baud_tick<=1'b1;
    end
    else begin
        counter<=counter+1;
        baud_tick=1'b0;
    end
end
endmodule
