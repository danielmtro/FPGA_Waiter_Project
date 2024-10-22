module uart_rx #(
    parameter CLKS_PER_BIT = (50000000/115200), // E.g. Baud rate = 115200 with FPGA clk = 50MHz
    parameter BITS_N       = 8, // Number of data bits per UART frame
    parameter PARITY_TYPE  = 0  // 0 for none, 1 for odd parity, 2 for even.
) (
    input clk,
    input rst,
    input uart_in,                // UART RX input (serial data line)
    
    output logic [BITS_N-1:0] data_rx, // Received data
    output logic valid_out,       // Handshake protocol: valid_out (when valid data is received)
    output logic ready_out,       // Handshake protocol: ready_out (when this UART module is ready to receive data)
    output logic parity_error     // Indicates a parity error if parity checking is enabled
);

    logic [BITS_N-1:0] data_rx_temp;
    logic [2:0] bit_n;
    logic baud_trigger;
    logic [BITS_N-1:0] shift_reg;
    logic parity_bit;

    enum {IDLE, START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT} current_state, next_state;

    integer counter = 0;

    // Setting baud rate
    assign baud_trigger = (counter == CLKS_PER_BIT-1);

    always_ff @(posedge clk) begin
        counter <= (counter == CLKS_PER_BIT-1) ? 0 : counter + 1;
    end

    // Next state logic
    always_comb begin
        case (current_state)
            IDLE:        next_state = (~uart_in) ? START_BIT : IDLE;  // Start on low signal (start bit)
            START_BIT:   next_state = baud_trigger ? DATA_BITS : START_BIT;
            DATA_BITS:   next_state = baud_trigger ? ((bit_n == BITS_N-1) ? (PARITY_TYPE ? PARITY_BIT : STOP_BIT) : DATA_BITS) : DATA_BITS;
            PARITY_BIT:  next_state = (PARITY_TYPE == 0) ? STOP_BIT : (baud_trigger ? STOP_BIT : PARITY_BIT);
            STOP_BIT:    next_state = baud_trigger ? IDLE : STOP_BIT;
            default:     next_state = IDLE;
        endcase
    end

    // State transition and data capture
    always_ff @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
            data_rx_temp <= 0;
            bit_n <= 0;
            parity_bit <= 0;
        end else begin
            current_state <= next_state;
            case (current_state)
                IDLE: begin
                    data_rx_temp <= 0;
                    bit_n <= 0;
                    parity_bit <= 0;
                end
                DATA_BITS: begin
                    if (baud_trigger) begin
                        data_rx_temp[bit_n] <= uart_in;
                        bit_n <= bit_n + 1'b1;
                    end
                end
                PARITY_BIT: begin
                    if (baud_trigger) begin
                        parity_bit <= uart_in;
                    end
                end
            endcase
        end
    end

    // Output logic
    always_comb begin
        data_rx = data_rx_temp;
        valid_out = 0;
        ready_out = 0;
        parity_error = 0;

        case (current_state)
            IDLE: ready_out = 1'b1;  // Ready to receive new data
            STOP_BIT: begin
                valid_out = baud_trigger ? 1'b1 : 1'b0;
                if (baud_trigger) begin
                    if (PARITY_TYPE != 0) begin
                        if (PARITY_TYPE == 1) // Odd parity
                            parity_error = (parity_bit == ~^data_rx_temp) ? 1'b0 : 1'b1;
                        else if (PARITY_TYPE == 2) // Even parity
                            parity_error = (parity_bit == ^data_rx_temp) ? 1'b0 : 1'b1;
                    end
                end
            end
        endcase
    end

endmodule
