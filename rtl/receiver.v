module receiver #(
    parameter PARITY_EN   = 1,      // 1 = Enable parity
    parameter PARITY_TYPE = 0,      // 0 = Even, 1 = Odd
    parameter XOR_KEY     = 8'h45   // 🔓 XOR KEY
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

    // Parity calculated on ENCRYPTED data
    always @(*) begin
        if (PARITY_TYPE == 0)
            calculated_parity = ^shift_reg;      // Even
        else
            calculated_parity = ~(^shift_reg);   // Odd
    end

    always @(posedge clk) begin
        if (rst) begin
            state          <= IDLE;
            sample_cnt     <= 0;
            bit_idx        <= 0;
            shift_reg      <= 0;
            data_out       <= 0;
            rdy            <= 0;
            parity_error   <= 0;
            received_parity <= 0;
        end else begin
            if (rdy_clr) begin
                rdy          <= 0;
                parity_error <= 0;
            end

            if (baud_tick2) begin
                case (state)
                    IDLE: if (!rx) begin
                        state <= START;
                        sample_cnt <= 0;
                    end

                    START: if (sample_cnt == 7) begin
                        if (!rx) begin
                            state <= DATA;
                            bit_idx <= 0;
                            sample_cnt <= 0;
                        end else
                            state <= IDLE;
                    end else
                        sample_cnt <= sample_cnt + 1;

                    DATA: if (sample_cnt == 15) begin
                        shift_reg[bit_idx] <= rx;
                        sample_cnt <= 0;
                        if (bit_idx == 7) begin
                            if (PARITY_EN)
                                state <= PARITY;
                            else
                                state <= STOP;
                        end else
                            bit_idx <= bit_idx + 1;
                    end else
                        sample_cnt <= sample_cnt + 1;

                    PARITY: if (sample_cnt == 15) begin
                        received_parity <= rx;
                        if (rx != calculated_parity)
                            parity_error <= 1'b1;
                        sample_cnt <= 0;
                        state <= STOP;
                    end else
                        sample_cnt <= sample_cnt + 1;

                    STOP: if (sample_cnt == 15) begin
                        if (rx) begin
                            // 🔓 XOR DECRYPTION
                            data_out <= shift_reg ^ XOR_KEY;
                            rdy <= 1'b1;
                        end
                        state <= IDLE;
                        sample_cnt <= 0;
                    end else
                        sample_cnt <= sample_cnt + 1;

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule