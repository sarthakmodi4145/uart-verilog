module transmitter #(
    parameter PARITY_EN   = 1,      // 1 = Enable parity
    parameter PARITY_TYPE = 0,      // 0 = Even, 1 = Odd
    parameter XOR_KEY     = 8'h45   // 🔐 XOR KEY
)(
    input  wire clk,
    input  wire wr_en,
    input  wire baud_tick1,
    input  wire rst,
    input  wire [7:0] data_in,
    output reg  tx,
    output reg  busy
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

    // Parity calculated on ENCRYPTED data
    always @(*) begin
        if (PARITY_TYPE == 0)
            parity_bit = ^shift_reg;      // Even parity
        else
            parity_bit = ~(^shift_reg);   // Odd parity
    end

    always @(posedge clk) begin
        if (rst) begin
            state     <= idle;
            busy      <= 1'b0;
            tx        <= 1'b1;
            bit_inx   <= 3'd0;
            shift_reg <= 8'd0;
        end else begin
            case (state)
                idle: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    if (wr_en) begin
                        // 🔐 XOR ENCRYPTION
                        shift_reg <= data_in ^ XOR_KEY;
                        busy      <= 1'b1;
                        bit_inx   <= 3'd0;
                        state     <= start;
                    end
                end

                start: if (baud_tick1) begin
                    tx    <= 1'b0;
                    state <= data;
                end

                data: if (baud_tick1) begin
                    tx <= shift_reg[bit_inx];
                    if (bit_inx == 3'd7) begin
                        if (PARITY_EN)
                            state <= parity;
                        else
                            state <= stop;
                    end else
                        bit_inx <= bit_inx + 1;
                end

                parity: if (baud_tick1) begin
                    tx    <= parity_bit;
                    state <= stop;
                end

                stop: if (baud_tick1) begin
                    tx    <= 1'b1;
                    busy  <= 1'b0;
                    state <= idle;
                end

                default: state <= idle;
            endcase
        end
    end
endmodule