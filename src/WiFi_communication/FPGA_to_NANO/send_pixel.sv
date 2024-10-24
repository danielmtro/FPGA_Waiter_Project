/**

*/

module send_pixel(
	input clk,
	input rst,
	input [11:0] pixel,
	input valid_in,            // Handshake protocol: valid_in (when `data_tx` is valid_in to be sent onto the UART).
	input ready_in,
		
	output logic uart_out,
	output logic ready_out,      // Handshake protocol: ready_out (when this UART module is ready_out to send data).
  	output logic valid_out
);

	logic uart_ready_out;
	logic [7:0] data_tx;
	logic uart_valid_out;
	logic uart_valid_in;

	// TX signals
	localparam CLKS_PER_BIT = (50000000/115200);

	uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(8),
        .PARITY_TYPE(0) // Even parity
	) uart_tx (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .valid_in(uart_valid_in),
        .uart_out(uart_out),
        .ready_out(uart_ready_out),
		.ready_in(ready_in),
		.baud_trigger(baud_trigger),
		.valid_out(uart_valid_out)
    );
	 
	logic [7:0] high_byte;
	logic [7:0] low_byte;
	
	always_comb begin
		high_byte = pixel[11:4];
		low_byte = {4'b0000, pixel[3:0]};
	end
	 
	enum {IDLE, SEND_HIGH_BYTE, SEND_LOW_BYTE} current_state, next_state, previous_state;
	 
	 //FSM next state logic
	 always_comb begin :fsm_next_state_logic
		next_state = current_state;
		
		case (current_state)
			IDLE: begin
				next_state = (valid_in && ready_in) ? SEND_HIGH_BYTE : IDLE;
			end
			SEND_HIGH_BYTE: begin
				next_state = uart_ready_out ? SEND_LOW_BYTE : SEND_HIGH_BYTE;
			end
			SEND_LOW_BYTE: begin
				next_state = uart_ready_out ? IDLE : SEND_LOW_BYTE;
			end
		endcase
	 end
	 
	 always_ff @(posedge clk) begin
		previous_state <= current_state;
		current_state <= (~rst) ? IDLE : next_state;
	 end
	 
	 //assert uart_valid_in pulse whenchanging from IDLE ->
	 assign uart_valid_in = (current_state != next_state && next_state != IDLE);
	 
	 //FSM state output
	 always_comb begin : FSM_state_output
	 
		valid_out = uart_valid_out;
		case (current_state)
		
			IDLE: begin 
				ready_out = 1; //NOTE will this work? should ensure that new pixel is only loaded in when in IDLE
				valid_out = 0;
				data_tx = high_byte;
			end
			SEND_HIGH_BYTE: begin
				ready_out = 0;
				data_tx = (next_state == SEND_LOW_BYTE) ? low_byte : high_byte;
			end
			SEND_LOW_BYTE: begin
				ready_out = 0;
				data_tx = low_byte;
			end
			default: begin
				ready_out = 0;
				valid_out = 0;
				data_tx = 1;
			end
		endcase
	 end

endmodule 