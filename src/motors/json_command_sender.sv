import lcd_inst_pkg::*;

module json_command_sender #(
    parameter CLKS_PER_BIT = 50_000_000/115_200,
    parameter BITS_N = 8,
    parameter NUM_BYTES = 25
    )(
    input clk,
    input rst,
    output logic uart_out,
    output logic ready         // Signal indicating the system is ready for a new command
);
    logic [4:0] byte_index = 0;
    logic [4:0] next_byte_index = 0;

    logic uart_valid;
    logic [BITS_N-1:0] current_byte = 8'b0;

    logic uart_ready;

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
    logic [0:NUM_BYTES-1][7:0] json_data 
    initial begin
        json_data[0] = _OPEN_BRACE
        _DOUBLE_QUOTE
        _T
        _DOUBLE_QUOTE
        _COLON
        _1
        _COMMA
        _DOUBLE_QUOTE
        _L
        _DOUBLE_QUOTE
        _COLON
        _0
        _PERIOD
        _5
        _COMMA
         _DOUBLE_QUOTE
        _R
        _DOUBLE_QUOTE
        _COLON
        _0
        _PERIOD
        _5
        _CLOSE_BRACE
        8'h0A
		  8'h0A// new line character
    end

    // current byte based on byte index
    always_comb begin
        current_byte = json_data[byte_index];
    end
	 
    // Control logic to send the JSON string byte by byte
    always_ff @(posedge clk) begin
        if (rst)
        begin
            byte_index <= 0;
            next_byte_index <= 0;
            uart_valid <= 1'b1;
        end 
		  else if (next_byte_index == NUM_BYTES) 
			  begin
				uart_valid <= 1'b0;
			  end
        else if (uart_ready)
        begin
            if(next_byte_index < NUM_BYTES)
					begin
						 byte_index <= next_byte_index;
						 uart_valid <= 1'b1;
						 next_byte_index <= next_byte_index + 1;
					end
        end 
    end

    // Ready signal when all bytes have been sent, including the newline
    assign ready = (next_byte_index == NUM_BYTES) && !uart_valid && uart_ready;  // Only ready after the last byte is fully sent

endmodule
