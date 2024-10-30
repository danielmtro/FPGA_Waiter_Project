module speed_fsm(

	input CLOCK_50,
	input [2:0] direction, // current state
	input [9:0] mic_freq,
	input [4:0] threshold_frequency,
	output [2:0] speed
);

	logic rst;
	
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
	
	// determine if we are in reset mode or not
	always_comb begin
		if(direction == 3'b001 || direction == 3'b011) begin
			rst = 0;
		end
		else begin
			rst = 1;
		end
	end
	
	logic [2:0] speed_temp = 0;
	
	// increment the temp speed if we are at the correct value
	always_ff @(posedge CLOCK_50) begin
		if(rst) begin
			speed_temp <= 0;
		end
		else if(mic_freq > threshold_frequency) begin
			speed_temp <= (speed_temp < 6) ? speed_temp + 1 : speed_temp;
		end
		else begin
			speed_temp <= speed_temp;
		end
	end
	
	
	always_comb begin
		
		// handle speeds out of control
		if(speed_temp >= 5) begin
			speed = 3;					// change this
		end
		else begin
			speed = speed_temp + 1;
		end
	
	end

endmodule