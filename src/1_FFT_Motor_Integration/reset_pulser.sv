/*
	
	Pulses an output value every 
*/

module reset_pulser(

	input clock_50,
	output rst
);

	
	// counts up to 2^27 - 1
	// should take about 2.68 seconds
	logic [26:0]i;
	always_ff @(posedge clock_50) begin
		i <= i + 1;		
	end
	
	assign rst = (i == 0);

endmodule