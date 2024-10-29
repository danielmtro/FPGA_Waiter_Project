module drive_motor(
	
	input CLOCK_50,
	input [3:0] direction, // should be the state
	input [2:0] speed,
	output uart_out 		  // uart output
);
	
	// each uart out module stored separately
	logic back_uart_out;
	logic forward_uart_out;
	logic stop_uart_out;
	logic turn_left_uart_out;
	logic right_back_uart_out;

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
	
	turn_left left (
		 .clk(CLOCK_50),
		 .speed(speed),
		 .rst(b_rst),
		 .uart_out(turn_left_uart_out),
		 .ready()
	);
	
	turn_right_back back (
		 .clk(CLOCK_50),
		 .speed(speed),
		 .rst(b_rst),
		 .uart_out(right_back_uart_out),
		 .ready()
	);
	
	// always comb block to select what direction we want the robot to go
	
	/*
	For reference: direction is an enum:
		IDLE_BASE, 	0	0000
      FORWARDS,	1	0001
		TURN,			2	0010
		TO_TABLE,	3	0011
      IDLE_TABLE,	4	0100
      BACKWARDS,	5	0101
		TURN_BACK,	6	0110
		RETURN_HOME,7	0111
      STOP			8	1000
	
	*/
	
	
	always_comb begin
		
		//FORWARDS or TO_TABLE
		if(direction == 4'b0001 || direction == 4'b0011) 
			begin
				uart_out = forward_uart_out;
			end
		//TURN
		else if (direction == 4'b0010) 
			begin
				uart_out = turn_left_uart_out;
			end
		//BACKWARDS or RETURN_HOME
		else if (direction == 4'b0101 || direction == 4'b0111)
			begin
				uart_out = back_uart_out;
			end
		//TURN_BACK
		else if (direction == 4'b0110)
			begin
				uart_out = right_back_uart_out;
			end
		//IDLE_BASE or IDLE_TABLE or STOP
		else
			begin
				uart_out = stop_uart_out;
			end
	end	
	
endmodule