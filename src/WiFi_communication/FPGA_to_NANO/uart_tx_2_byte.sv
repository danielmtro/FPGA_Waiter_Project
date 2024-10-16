module uart_tx_2_bytes (
    input 	logic clk,          // Clock signal
    input 	logic reset,        // Active high reset
    input 	logic [11:0] pixel, // 12-bit RGB pixel data
    input 	logic send_pixel_flag,   // Signal to trigger sending the pixel
    output 	logic tx_port,      // UART TX line
    output 	logic ready         // Ready signal to indicate UART is ready for next data
);

    // UART parameters
    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 50000000;  // Assuming 50 MHz clock
    parameter BAUD_DIV = CLOCK_FREQ / BAUD_RATE;

    // UART state machine states
    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        SEND_HIGH_BYTE,
        SEND_LOW_BYTE,
        STOP_BIT
    } uart_state_t;
    
    uart_state_t current_state, next_state;

    logic [7:0] tx_byte;   		// Byte to be transmitted
    logic [15:0] baud_counter; 	// Baud rate counter
    logic tx_reg;
    
    // Output assignment
    assign tx_port = tx_reg;

    // Pixel data splitting
    logic [7:0] high_byte = pixel[11:4];      // High byte from the 12-bit pixel
    logic [7:0] low_byte = {pixel[3:0], 4'b0};  // Low byte shifted

	 //state register
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= IDLE;
            tx_reg <= 1;  // Idle line is high
            ready <= 1;
        end 
		  else begin
            current_state <= next_state;
        end
    end
	 
	 
	 
	 //BAUD counter
	 always_ff @(posedge clk) begin
		baud_counter = (reset || baud_counter == (BAUD_DIV - 1)) ? 0 : baud_counter + 1;
	 end

	 logic [3:0] bit_counter;
	 initial bit_counter = 0;
	 
	 
	 //NEXT STATE LOGIC
	 always_comb begin : next_state_logic
		next_state = current_state;
		
		case (current_state)
			IDLE: begin
				next_state = (send_pixel_flag) ? START_BIT : IDLE;
			end
			START_BIT: begin
				next_state = baud_counter ? SEND_HIGH_BYTE : START_BIT;
			end
			SEND_HIGH_BYTE: begin
				next_state = (bit_counter == 7) ? SEND_LOW_BYTE : SEND_HIGH_BYTE;
			end
			SEND_LOW_BYTE: begin
				next_state = (bit_counter == 7) ? STOP_BIT : SEND_LOW_BYTE;
			end
			STOP_BIT: begin
				
			end
			
		endcase
	end
	 
	 
    always_ff @(posedge clk) begin
        case (current_state)
            IDLE: begin
                if (send_pixel_flag) begin
                    tx_byte <= high_byte;
                    ready <= 0;
                    next_state <= START_BIT;
                end else begin
                    next_state <= IDLE;
                    ready <= 1;
                end
            end
            START_BIT: begin
                if (baud_counter == 0) begin
                    tx_reg <= 0; // Start bit
                    next_state <= SEND_HIGH_BYTE;
                end
            end
            SEND_HIGH_BYTE: begin
                if (baud_counter == 0) begin
                    tx_reg <= tx_byte[0];
                    tx_byte <= {1'b0, tx_byte[7:1]}; // Shift out the high byte
						  bit_counter <= bit_counter + 1;
                    if (bit_counter == 7) begin
                        next_state <= SEND_LOW_BYTE;
                        tx_byte <= low_byte; // Load low byte
								bit_counter <= 0;
                    end
                end
            end
            SEND_LOW_BYTE: begin
                if (baud_counter == 0) begin
                    tx_reg <= tx_byte[0];
                    tx_byte <= {1'b0, tx_byte[7:1]}; // Shift out the low byte
						  bit_counter <= bit_counter + 1;
                    if (&tx_byte[7:1]) begin
                        next_state <= STOP_BIT;
								bit_counter <= 0;
                    end
                end
            end
            STOP_BIT: begin
                if (baud_counter == 0) begin
                    tx_reg <= 1;  // Stop bit
                    ready <= 1;
                    next_state <= IDLE;
                end
            end
        endcase
    end
endmodule
