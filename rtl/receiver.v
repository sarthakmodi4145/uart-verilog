module receiver (
    input  wire clk,
    input  wire rst,
    input  wire baud_tick2,   // MUST be 16x baud
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
    reg [3:0] sample_cnt;   // counts 0–15
    reg [2:0] bit_idx;      // 8 bits
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

            if (rdy_clr)
                rdy <= 1'b0;

            if (baud_tick2) begin
                case (state)

                    // ---------------- IDLE ----------------
                    IDLE: begin
                        if (rx == 1'b0) begin   // start bit detected
                            state      <= START;
                            sample_cnt <= 4'd0;
                        end
                    end

                    // ---------------- START ----------------
                    START: begin
                        sample_cnt <= sample_cnt + 1;

                        if (sample_cnt == 4'd7) begin
                            // mid of start bit
                            if (rx == 1'b0) begin
                                sample_cnt <= 4'd0;
                                bit_idx    <= 3'd0;
                                state      <= DATA;
                            end else begin
                                state <= IDLE; // false start
                            end
                        end
                    end

                    // ---------------- DATA ----------------
                    DATA: begin
                        sample_cnt <= sample_cnt + 1;

                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            shift_reg[bit_idx] <= rx;
                            bit_idx <= bit_idx + 1;

                            if (bit_idx == 3'd7)
                                state <= STOP;
                        end
                    end

                    // ---------------- STOP ----------------
                    STOP: begin
                        sample_cnt <= sample_cnt + 1;

                        if (sample_cnt == 4'd15) begin
                            data_out <= shift_reg;
                            rdy      <= 1'b1;
                            state    <= IDLE;
                            sample_cnt <= 4'd0;

                            $display("RX DONE @ %t, data = %h", $time, shift_reg);
                        end
                    end

                endcase
            end
        end
    end

endmodule