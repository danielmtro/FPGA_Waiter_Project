module pixel_sender #(
    parameter CLKS_PER_BIT = 50_000_000/9600,
    parameter BITS_N = 8
    )(
    input clk,
    input rst,
    input logic [11:0] pixel,
    output logic uart_out,
    output logic ready         // Signal indicating the system is ready for a new command
);

    logic uart_valid;
    logic [BITS_N-1:0] current_byte = 8'b0;
    logic uart_ready;

    logic[1:0] byte_index, next_byte_index;

    logic [BITS_N-1:0] high_byte, low_byte;

    always_comb begin
        // take the first 8 bits as the high bye
		high_byte = pixel[11:4];

        // take the next 4 bits as low byte padded with zeroes
		low_byte = {4'b0000, pixel[3:0]};

        // determine what the current byte is
        current_byte = (byte_index == 0) ? high_byte : low_byte;
	end

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


    // Control logic to send the JSON string byte by byte
    always_ff @(posedge clk) begin
       if (rst)
        begin
            byte_index <= 0;
            next_byte_index <= 0;
            uart_valid <= 1'b0;
        end 
		else if (next_byte_index == 2) // if we have reached the end of it then set it slow 
			  begin
				uart_valid <= 1'b0; //  we've reached the end so set valid low
			  end
      else if (uart_ready)
        begin
            if(next_byte_index < 2 && uart_valid)
                begin
                        byte_index <= next_byte_index;
                        uart_valid <= 1'b1;
                        next_byte_index <= next_byte_index + 1;
                end
				else begin
					uart_valid <= 1'b1;
				end
        end 
		else begin
			// if we are sending data get ready to move to the next
			byte_index <= next_byte_index;
		end
    end

    // Ready signal when all bytes have been sent, including the newline
    assign ready = (next_byte_index == 2) && (uart_ready == 1'b1) && (uart_valid == 1'b0);  // Only ready after the last byte is fully sent

endmodule
