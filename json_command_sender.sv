module json_command_sender #(
    parameter CLKS_PER_BIT = 50_000_000/115_200,
    parameter BITS_N = 8,
    parameter NUM_BYTES = 25
    )(
    input clk,
    input rst,
    input valid,
    output logic uart_out,
    output logic ready         // Signal indicating the system is ready for a new command
);
    logic [4:0] byte_index = 0;
    logic uart_valid;
    logic [BITS_N-1:0] current_byte = 8'b0;
    logic uart_ready;
    logic send_next_byte;  // New signal to indicate when to send the next byte

    // UART transmitter instance
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N)
    ) uart (
        .clk(clk),
        .rst(rst),
        .data_tx(current_byte),
        .uart_out(uart_out),
        .valid(uart_valid),
        .ready(uart_ready)
    );

    // Hard-coded 25-byte JSON message: {"T":11,"L":164,"R":164}\n
    logic [0:NUM_BYTES-1][7:0] json_data = {
        8'h7B, 8'h22, 8'h54, 8'h22, 8'h3A, 8'h31, 8'h31, 8'h2C, // {"T":11,
        8'h22, 8'h4C, 8'h22, 8'h3A, 8'h31, 8'h36, 8'h34, 8'h2C, // "L":164,
        8'h22, 8'h52, 8'h22, 8'h3A, 8'h31, 8'h36, 8'h34, 8'h7D, 8'h0A  // "R":164}\n
    };

    // Control logic to send the JSON string byte by byte
    always_ff @(posedge clk) begin
        if (rst) begin
            byte_index <= 0;
            uart_valid <= 0;
            current_byte <= 8'b0;
        end else if (uart_ready && byte_index < NUM_BYTES+1 && valid) begin
            if (send_next_byte) begin
                current_byte <= json_data[byte_index];  // Get the next byte to send
                uart_valid <= 1;                        // Signal valid to send the byte
                byte_index <= byte_index + 1;           // Increment the byte index
            end else if (uart_ready) begin
                uart_valid <= 0;
            end
        end
    end

    // Generate send_next_byte signal for single cycle assertion of uart_valid
    always_ff @(posedge clk) begin
        if (rst) begin
            send_next_byte <= 0;
        end else if (uart_ready && !uart_valid && !send_next_byte) begin
            send_next_byte <= 1;    // Assert for one cycle when UART is ready and bytes remain
        end else begin
            send_next_byte <= 0;    // Deassert on next clock
        end
    end

    // Ready signal when all bytes have been sent, including the newline
    assign ready = (byte_index == NUM_BYTES) && send_next_byte;  // Only ready after the last byte is fully sent

endmodule
