/*
Needs to be modified to take in 12 bit data. But I don't have a hex file of that for now
*/

module inversion_filter (
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

	logic[3:0] red, green, blue;
	logic[3:0] red_inv, green_inv, blue_inv;
	
	always_comb begin
		red 	= data_in[11:8];
		green = data_in[7:4];
		blue  = data_in[3:0];
	end 
	
	always_comb begin
		red_inv 		= 4'b1111 - red;
		green_inv 	= 4'b1111 - green;
		blue_inv 	= 4'b1111 - blue;
	end 
	
	always_comb begin
			if (freq_flag > 1) begin
				data_out = {red_inv, green_inv, blue_inv};
			end
			else begin
				data_out = {red, green, blue};
			end
	end
	
endmodule 