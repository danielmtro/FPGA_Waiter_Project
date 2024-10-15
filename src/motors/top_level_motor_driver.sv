module top_level_motor_driver #(
    parameter CLKS_PER_BIT = 50_000_000/115_200,
    parameter BITS_N = 8,
    parameter NUM_BYTES = 25
) (
    input wire CLOCK_50,
    output [17:0] LEDR,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    output wire GPIO[5] // GPIO5
);

wire ready;

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

always_ff @(posedge CLOCK_50) 
begin
	if(reset_signal) 
	begin
		LED[5] <= ~LED[5];
	end
end
			  


json_command_sender #(
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .BITS_N(BITS_N),
    .NUM_BYTES(NUM_BYTES)
) json (
    .clk(CLOCK_50),
    .rst(reset_signal),
    .uart_out(UART_OUT),
    .ready(ready)
);

assign LEDR[17] = SW[17];
assign LEDR[0] = UART_OUT;
assign LEDR[2] = ready;

endmodule