module top_level_motor_driver (
    input wire CLOCK_50,
    output [17:0] LEDR,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    inout wire [35:0]GPIO // GPIO5
);


wire uart_out;
logic uart_ready;

wire debounced_key;
assign LEDR[1] = ~debounced_key;

wire reset_signal;

	// debounce key
	debounce #(.DELAY_COUNTS(2500)) d_i (
				  .clk(CLOCK_50),
				  .button(KEY[0]),
				  .button_pressed(debounced_key));
				  
	edge_detect e0 (
		.clk(CLOCK_50),
		.button(~debounced_key),
		.button_edge(reset_signal)
	);


	json_command_sender json (
		 .clk(CLOCK_50),
		 .rst(SW[0]),
		 .uart_out(uart_out),
		 .ready(uart_ready)
	);
	
	assign GPIO[5] = uart_out;
	assign LEDR[17] = SW[17];
	assign LEDR[0] = SW[0];
	assign LEDR[2] = uart_ready;

endmodule