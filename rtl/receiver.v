module receiver (
    input  wire clk,
    input  wire rst,
    input  wire baud_tick2,
    input  wire rx,
    input  wire rdy_clr,
    output reg  [7:0] data_out,
    output reg  rdy
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;
    reg [3:0] sample_cnt;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            sample_cnt <= 4'd0;
            bit_idx    <= 3'd0;
            shift_reg  <= 8'd0;
            data_out   <= 8'd0;
            rdy        <= 1'b0;
        end else begin
            // Clear ready flag when requested
            if (rdy_clr)
                rdy <= 1'b0;

            if (baud_tick2) begin
                case (state)

                    // ---------------- IDLE ----------------
                    IDLE: begin
                        if (rx == 1'b0) begin  // Start bit detected
                            state      <= START;
                            sample_cnt <= 4'd0;
                        end
                    end

                    // ---------------- START ----------------
                    START: begin
                        if (sample_cnt == 4'd7) begin
                            // Middle of start bit - validate
                            if (rx == 1'b0) begin
                                // Valid start bit - go to DATA
                                state      <= DATA;
                                sample_cnt <= 4'd0;
                                bit_idx    <= 3'd0;
                            end else begin
                                // False start
                                state <= IDLE;
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end

                    // ---------------- DATA ----------------
                    DATA: begin
                        if (sample_cnt == 4'd15) begin
                            // Middle of data bit - sample it
                            shift_reg[bit_idx] <= rx;
                            sample_cnt <= 4'd0;
                            
                            if (bit_idx == 3'd7)
                                state <= STOP;
                            else
                                bit_idx <= bit_idx + 1;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end

                    // ---------------- STOP ----------------
                    STOP: begin
                        if (sample_cnt == 4'd15) begin
                            // Middle of stop bit
                            if (rx == 1'b1) begin
                                data_out <= shift_reg;
                                rdy      <= 1'b1;
                                $display("RX DONE @ %t, data = %h", $time, shift_reg);
                            end
                            state      <= IDLE;
                            sample_cnt <= 4'd0;
                        end else begin
                            sample_cnt <= sample_cnt + 1;
                        end
                    end

                endcase
            end
        end
    end
endmodule