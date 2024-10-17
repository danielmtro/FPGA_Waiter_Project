import lcd_inst_pkg::*;

module forward #(
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
    logic [0:NUM_BYTES-1][7:0] json_data;
    initial begin
        json_data[0] = _OPEN_BRACE;
        json_data[1] =_DOUBLE_QUOTE;
        json_data[2] =_T;
        json_data[3] =_DOUBLE_QUOTE;
        json_data[4] =_COLON;
        json_data[5] =_1;
        json_data[6] =_COMMA;
        json_data[7] =_DOUBLE_QUOTE;
        json_data[8] =_L;
        json_data[9] =_DOUBLE_QUOTE;
        json_data[10] =_COLON;
        json_data[11] =_0;
        json_data[12] =_PERIOD;
        json_data[13] =_5;
        json_data[14] =_COMMA;
        json_data[15] =_DOUBLE_QUOTE;
        json_data[16] =_R;
        json_data[17] =_DOUBLE_QUOTE;
        json_data[18] =_COLON;
        json_data[19] =_0;
        json_data[20] =_PERIOD;
        json_data[21] =_5;
        json_data[22] =_CLOSE_BRACE;
        json_data[23] =8'h0A;
		json_data[24] =8'h0A; // new line character
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
            uart_valid <= 1'b0;
        end 
		else if (next_byte_index == NUM_BYTES) 
			  begin
				uart_valid <= 1'b0; //  we've reached the end so set valid low
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
    assign ready = (byte_index == NUM_BYTES) && uart_ready && (!uart_valid);  // Only ready after the last byte is fully sent

endmodule
