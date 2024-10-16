/**

*/

module send_pixel(
	input clk,
   input rst,
   input [11:0] pixel,
	input valid_in,            // Handshake protocol: valid_in (when `data_tx` is valid_in to be sent onto the UART).
	input logic ready_in,
		
	output logic uart_out,
   output logic ready_out      // Handshake protocol: ready_out (when this UART module is ready_out to send data).
  	output logic valid_out
);

	logic uart_ready_out;
	logic data_tx;
	logic uart_valid_out;
	
	uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT_115200),
        .BITS_N(8),
        .PARITY_TYPE(0) // Even parity
    ) UART_TX (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .valid_in(uart_valid_in),
		  .valid_out(uart_valid_out),
        .uart_out(uart_out),
        .ready_out(uart_ready_out)
    );
	 
	logic [7:0] high_byte;
	logic [7:0] low_byte;
	
	always_comb begin
		high_byte = pixel[11:4];
		low_byte = {4{0}, pixel[3:0]};
	end
	 
	enum {IDLE, SEND_HIGH_BYTE, SEND_LOW_BYTE} current_state, next_state;
	 
	 //FSM next state logic
	 
	 always_comb begin :fsm_next_state_logic
		next_state = current_state;
		
		case (current_state)
		
			IDLE: begin
				next_state = valid_in ? SEND_HIGH_BYTE : IDLE;
			end
			SEND_HIGH_BYTE: begin
				next_state = uart_ready_out ? SEND_LOW_BYTE : SEND_HIGH_BYTE;
			end
			SEND_LOW_BYTE: begin
				next_state = uart_ready_out ? IDLE : SEND_LOW_BYTE;
			end
	 end
	 
	 always_ff @(posedge clk) begin
		current_state = (rst) ? IDLE : next_state;
	 end
	 
	 always_comb begin : FSM_state_output
	 
		valid_out = uart_valid_out;
		case (current_state);
		
			IDLE: begin 
				ready_out = 1; //NOTE will this work? should ensure that new pixel is only loaded in when in IDLE
				valid_out = 0;
			end
			SEND_HIGH_BYTE: begin
				read_out = 0;
				data_tx = high_byte;
			end
			SEND_LOW_BYTE: begin
				ready_out = 0;
				data_tx = low_byte;
			end
	 end

endmodule 