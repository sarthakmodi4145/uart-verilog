module transmitter #(
    parameter PARITY_EN = 1,      // 1 = Enable parity, 0 = Disable
    parameter PARITY_TYPE = 0     // 0 = Even parity, 1 = Odd parity
)(
    input wire clk,
    input wire wr_en,
    input wire baud_tick1,
    input wire rst,  
    input wire [7:0] data_in,
    output reg tx,
    output reg busy
);
    localparam idle   = 3'b000;
    localparam start  = 3'b001;
    localparam data   = 3'b010;
    localparam parity = 3'b011;
    localparam stop   = 3'b100;
    
    reg [2:0] state;
    reg [2:0] bit_inx;
    reg [7:0] shift_reg;
    reg parity_bit;

    
    always @(*) begin
        if (PARITY_TYPE == 0)  
            parity_bit = ^shift_reg;  
        else                   
            parity_bit = ~(^shift_reg);
    end

    always @(posedge clk) begin 
        if (rst) begin 
            state <= idle;
            busy <= 1'b0;
            tx <= 1'b1;
            bit_inx <= 3'd0;
            shift_reg <= 8'b0;
        end
        else begin
            case(state)
                idle: begin 
                    tx <= 1'b1;
                    busy <= 1'b0;
                    if (wr_en) begin 
                        shift_reg <= data_in;
                        busy <= 1'b1;
                        bit_inx <= 3'd0;
                        state <= start;
                    end
                end

                start: begin
                    if (baud_tick1) begin
                        tx <= 1'b0;
                        state <= data;
                    end
                end

                data: begin
                    if (baud_tick1) begin
                        tx <= shift_reg[bit_inx];
                        
                        if (bit_inx == 3'd7) begin
                            if (PARITY_EN)
                                state <= parity;
                            else
                                state <= stop;
                        end else
                            bit_inx <= bit_inx + 1;
                    end
                end
                
                parity: begin
                    if (baud_tick1) begin
                        tx <= parity_bit;
                        state <= stop;
                    end
                end
                
                stop: begin
                    if (baud_tick1) begin
                        tx <= 1'b1;
                        busy <= 1'b0;
                        state <= idle;
                    end
                end
                
                default: state <= idle;
            endcase
        end
    end
endmodule