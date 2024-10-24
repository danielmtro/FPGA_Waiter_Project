module brightness_filter (

	input logic 			clk,
	input logic 			reset,
	input logic [1:0] 	freq_flag,
	
	//Sink ports
	input  logic [11:0] 	data_in,
	input logic 			sop_in,
	input logic 			eop_in,
	input logic 			valid_in,
	
	//receiving back pressure from source
	input logic 			ready_in,
	
	//put back pressure on previous module
	output logic 			ready_out,
	
	//source ports
	output logic [11:0] 	data_out,
	output logic 			sop_out,
	output logic 			eop_out,
	output logic 			valid_out
	);
	
	always_comb begin
		ready_out = ready_in;
		eop_out = eop_in;
		sop_out = sop_in;
		valid_out = valid_in && (!reset);
	end
	
	logic [3:0] red, green, blue;
	logic [3:0] red_br, green_br, blue_br;
	
	logic [3:0] MAX_VAL;
	assign MAX_VAL = 4'b1111;
	
	always_comb begin
		red 	= data_in[11:8];
		green = data_in[7:4];
		blue 	= data_in[3:0];
	end
	
	always_comb begin
		red_br 	= (red * (freq_flag + 1) > (MAX_VAL)) ? MAX_VAL : (freq_flag + 1) * red;
		green_br = (green * (freq_flag + 1) > (MAX_VAL)) ? MAX_VAL : (freq_flag + 1) * green;
		blue_br 	= (blue *  (freq_flag + 1) > (MAX_VAL)) ? MAX_VAL : (freq_flag + 1) * blue;
		
		
	end
	
	always_comb begin
			data_out = {red_br, green_br, blue_br};
	end

	
endmodule 