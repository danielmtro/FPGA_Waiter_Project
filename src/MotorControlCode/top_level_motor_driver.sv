module top_level_motor_driver (
    input wire CLOCK_50,
    output [17:0] LEDR,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    inout wire [35:0]GPIO // GPIO5
);


	logic [3:0] debounced_keys;
	logic [3:0] edge_detect_keys;
	
	// debounce key
	genvar i;
	generate
		for(i = 0; i < 4; ++i) begin : debouncing_time
			debounce #(.DELAY_COUNTS(2500)) d_0 (
		   			  .clk(CLOCK_50),
						  .button(KEY[i]),
						  .button_pressed(debounced_keys[i])); 
		end : debouncing_time
	endgenerate
	
	
	// edging time
	
	genvar j;
	generate
		for(j = 0; j < 4; ++j) begin : edge_time
			edge_detect e0 (
					.clk(CLOCK_50),
					.button(~debounced_keys[j]),
					.button_edge(edge_detect_keys[j])
				);
		end : edge_time
	endgenerate
				  

	
	logic back_uart_out;
	logic forward_uart_out;
	logic stop_uart_out;
	logic [1:0]direction;
	logic uart_out;
		
	logic [2:0] speed;
	assign speed = SW[2:0];
	
	forward fward (
		 .clk(CLOCK_50),
		 .rst(edge_detect_keys[0]),
		 .speed(speed),
		 .uart_out(forward_uart_out),
		 .ready()
	);
	
	backwards back (
		 .clk(CLOCK_50),
		 .speed(speed),
		 .rst(edge_detect_keys[1]),
		 .uart_out(back_uart_out),
		 .ready()
	);
	
	stop stop_sequence (
		.clk(CLOCK_50),
		.rst(edge_detect_keys[2]),
		.uart_out(stop_uart_out),
		.ready()
	);
	
	direction_fsm dfsm (
		.clk(CLOCK_50),
		.button_edge_0(edge_detect_keys[0]),
		.button_edge_1(edge_detect_keys[1]),
		.button_edge_2(edge_detect_keys[2]),
		.direction(direction)
	);
	
	
	
	// always comb block to select what direction we want the robot to go
	always_comb begin
		
		if(direction == 2'b00) 
			begin
				uart_out = forward_uart_out;
			end
		else if (direction == 2'b01)
			begin
				uart_out = back_uart_out;
			end
		else
			begin
				uart_out = stop_uart_out;
			end
	end	
	
	
	// basic testing
	
//	logic json_uart_out;
//	json_command_sender jcs(
//		.clk(CLOCK_50),
//		.speed(speed),
//		.rst(edge_detect_keys[3]),
//		.uart_out(json_uart_out),
//		.ready()
//	);
//	
	assign GPIO[5] = uart_out;
	
	// view the current state
	assign LEDR[17] = direction[1];
	assign LEDR[16] = direction[0];
//	assign LEDR[2] = uart_ready;

endmodule