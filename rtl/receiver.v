module receiver #(
    parameter PARITY_EN = 1,      // 1 = Enable parity, 0 = Disable
    parameter PARITY_TYPE = 0     // 0 = Even parity, 1 = Odd parity
)(
    input  wire clk,
    input  wire rst,
    input  wire baud_tick2,
    input  wire rx,
    input  wire rdy_clr,
    output reg  [7:0] data_out,
    output reg  rdy,
    output reg  parity_error
);

    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b010;
    localparam PARITY = 3'b011;
    localparam STOP   = 3'b100;

    reg [2:0] state;
    reg [3:0] sample_cnt;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;
    reg received_parity;
    reg calculated_parity;

    
    always @(*) begin
        if (PARITY_TYPE == 0)  
            calculated_parity = ^shift_reg;
        else                    
            calculated_parity = ~(^shift_reg);
    end

    always @(posedge clk) begin
        if (rst) begin
            state          <= IDLE;
            sample_cnt     <= 4'd0;
            bit_idx        <= 3'd0;
            shift_reg      <= 8'd0;
            data_out       <= 8'd0;
            rdy            <= 1'b0;
            parity_error   <= 1'b0;
            received_parity <= 1'b0;
        end else begin
            
            if (rdy_clr) begin
                rdy <= 1'b0;
                parity_error <= 1'b0;
            end

            if (baud_tick2) begin
                case (state)

                    
                    IDLE: begin
                        if (rx == 1'b0) begin  
                            state      <= START;
                            sample_cnt <= 4'd0;
                            parity_error <= 1'b0;
                        end
                    end

                    
                    START: begin
                        if (sample_cnt == 4'd7) begin
                            
                            if (rx == 1'b0) begin
                                state      <= DATA;
                                sample_cnt <= 4'd0;
                                bit_idx    <= 3'd0;
                            end else begin
                                state <= IDLE;
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end

                   
                    DATA: begin
                        if (sample_cnt == 4'd15) begin
                            shift_reg[bit_idx] <= rx;
                            sample_cnt <= 4'd0;
                            
                            if (bit_idx == 3'd7) begin
                                if (PARITY_EN)
                                    state <= PARITY;
                                else
                                    state <= STOP;
                            end else
                                bit_idx <= bit_idx + 1;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end

                    
                    PARITY: begin
                        if (sample_cnt == 4'd15) begin
                            received_parity <= rx;
                            sample_cnt <= 4'd0;
                            state <= STOP;
                            
                           
                            if (received_parity != calculated_parity) begin
                                parity_error <= 1'b1;
                                $display("PARITY ERROR @ %t: Expected %b, Got %b", 
                                         $time, calculated_parity, received_parity);
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end

                   
                    STOP: begin
                        if (sample_cnt == 4'd15) begin
                            if (rx == 1'b1) begin
                                data_out <= shift_reg;
                                rdy      <= 1'b1;
                                $display("RX DONE @ %t, data = %h, parity_error = %b", 
                                         $time, shift_reg, parity_error);
                            end
                            state      <= IDLE;
                            sample_cnt <= 4'd0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end
                    
                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule