module colour_detect(
	input clk,
	input [11:0] data_in,
	input [3:0] upper_thresh,
	input [16:0] address,
	input sop,
	output [11:0] data_out,
	output [16:0] red_pixels
	
);

	logic [3:0] r;
	logic [3:0] g;
	logic [3:0] b;
	
	assign r = data_in[11:8];
	assign g = data_in[7:4];
	assign b = data_in[3:0];
	
	
	// Prototype a counter
	logic [16:0] prev_address;
	logic [16:0] red_pixel_count;
	
	// create an appropriate counter for red pixels
	always_ff @(posedge clk) begin
		prev_address <= address;
		
		if(sop) begin
			red_pixel_count <= 0;
		end
		else if(prev_address != address) begin
			
			// increment red pixel count
			if(is_red) begin
				red_pixel_count <= red_pixel_count + 1;
			end
		end
	end
	
	// signals based on thresholding
	logic is_red;
	assign is_red = (r > g) & (r > b) & (r >= upper_thresh);

	// determine output based on colours
	always_comb begin
		// determine if r is dominant
		if(is_red) begin
			data_out = {4'b1111, 8'b00000000};
		end	
		else begin
			data_out = 12'b000000000000;
		end
	end
	
	
	assign red_pixels = red_pixel_count;
	
	
endmodule
