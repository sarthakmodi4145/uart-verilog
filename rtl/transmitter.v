module transmitter(input wire clk,input wire wr_en,input wire baud_tick,input wire rst,  input wire [7:0] data_in,output reg tx,output reg busy);
localparam idle=2'b00,start=2'b01,data=2'b10,stop=2'b11;
reg [1:0] state;
reg [2:0] bit_inx;
reg [7:0] shift_reg;

always @(posedge clk) begin 
    if(rst) begin 
        state<=idle;
        busy<=1'b0;
        tx<=1'b1;
        bit_inx<=3'd0;
        shift_reg<=7'b0;
    end
    else begin
        case(state)
        idle:begin 
            tx<=1'b1;
            busy<=1'b0;
            if(wr_en) begin 
                shift_reg<=data_in;
                busy<=1'b1;
                bit_inx<=3'd0;
                state<=start;
            end
        end

        start: begin
            if(baud_tick) begin
                tx<=1'b0;
                state<=data;
            end
        end

        data: begin
            if(baud_tick) begin
                tx<=shift_reg[bit_inx];
                bit_inx<=bit_inx+1;

                if(bit_inx==3'd7)
                    state<=stop;
            end
        end
        stop:begin
            if(baud_tick==1'b1) begin
                tx<=1'b1;
                state<=idle;
            end
        end

        endcase
    end
end

endmodule