module speed_fsm(

	input CLOCK_50,
	input [2:0] direction, // current state
	input [9:0] mic_freq,
	input [4:0] threshold_frequency,
	output [2:0] speed
);

	logic rst;
	
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