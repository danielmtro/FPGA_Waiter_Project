module top_level_motor_driver #(
    parameter CLKS_PER_BIT = 50_000_000/115_200,
    parameter BITS_N = 8
) (
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


	json_command_sender #(
		 .CLKS_PER_BIT(CLKS_PER_BIT),
		 .BITS_N(BITS_N)
	) json (
		 .clk(CLOCK_50),
		 .rst(SW[0]),
		 .uart_out(uart_out),
		 .ready(uart_ready)
	);

//    uart_tx #(
//        .CLKS_PER_BIT(CLKS_PER_BIT),
//        .BITS_N(BITS_N)
//    ) uart (
//        .clk(CLOCK_50),
//        .rst(SW[0]),
//        .data_tx(8'h7b),
//        .uart_out(uart_out),
//        .valid(1'b1),
//        .ready(uart_ready)
//    );
	
	assign GPIO[5] = uart_out;
	assign LEDR[17] = SW[17];
	assign LEDR[0] = SW[0];
	assign LEDR[2] = uart_ready;

endmodule