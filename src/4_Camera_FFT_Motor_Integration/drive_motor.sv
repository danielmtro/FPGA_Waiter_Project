module drive_motor(
	
	input CLOCK_50,
	input [2:0] direction, // should be the state
	input [2:0] speed,
	output uart_out 		  // uart output
);
	
	// each uart out module stored separately
	logic back_uart_out;
	logic forward_uart_out;
	logic stop_uart_out;

	// create reset signals
	logic f_rst, b_rst, s_rst;
	
	continous_motor_control cmc (
		.clk(CLOCK_50),
		.direction(direction),
		.forward_rst(f_rst),
		.reverse_rst(b_rst),
		.stop_rst(s_rst)
	);
	
	forward fward (
		 .clk(CLOCK_50),
		 .rst(f_rst),
		 .speed(speed),
		 .uart_out(forward_uart_out),
		 .ready()
	);
	
	backwards back (
		 .clk(CLOCK_50),
		 .speed(speed),
		 .rst(b_rst),
		 .uart_out(back_uart_out),
		 .ready()
	);
	
	stop stop_sequence (
		.clk(CLOCK_50),
		.rst(s_rst),
		.uart_out(stop_uart_out),
		.ready()
	);
	
	// always comb block to select what direction we want the robot to go
	always_comb begin
		
		if(direction == 3'b001) 
			begin
				uart_out = forward_uart_out;
			end
		else if (direction == 3'b011)
			begin
				uart_out = back_uart_out;
			end
		else
			begin
				uart_out = stop_uart_out;
			end
	end	
	
endmodule