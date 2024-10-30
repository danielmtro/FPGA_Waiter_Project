module colour_detect(
	input clk,
	input [11:0] data_in,
	input [3:0] upper_thresh,
	input [16:0] address,
	input sop,
	input [1:0] colour,
	output [11:0] data_out,
	output [16:0] colour_pixels
	
);

	localparam RED = 0;
	localparam GREEN = 1;
	localparam BLUE = 2;

	logic [3:0] r;
	logic [3:0] g;
	logic [3:0] b;
	
	assign r = data_in[11:8];
	assign g = data_in[7:4];
	assign b = data_in[3:0];
	
	
	// Prototype a counter
	logic [16:0] prev_address;
	logic [16:0] pixel_count;
	
	// create an appropriate counter for red pixels
	always_ff @(posedge clk) begin
		prev_address <= address;
		
		if(sop) begin
			pixel_count <= 0;
		end
		
		// increment red pixel count
		else if(prev_address != address) begin
			case (colour)
				RED: begin
					if(is_red) begin
						pixel_count <= pixel_count + 1;
					end
				end
				GREEN: begin
					if(is_green) begin
						pixel_count <= pixel_count + 1;
					end
				end
				BLUE: begin
					if(is_blue) begin
						pixel_count <= pixel_count + 1;
					end
				end
			endcase
		end
	end
	
	// signals based on thresholding
	logic is_red;
	logic is_green;
	logic is_blue;
	
	assign is_red 		= (r > g) & (r > b) & (r >= upper_thresh);
	assign is_green 	= (g > r) & (g > b) & (g >= upper_thresh);
	assign is_blue 	= (b > r) & (b > g) & (b >= upper_thresh);

	// determine output based on colours
	always_comb begin
		// determine if r is dominant
		case (colour)
			RED: begin
				if(is_red) begin
					data_out = {4'b1111, 8'b00000000};
				end
				else begin
					data_out = 12'b000000000000;
				end
			end
			
			GREEN: begin
				if(is_green) begin
					data_out = {12'b0000_1111_0000};
				end
				else begin
					data_out = 12'b000000000000;
				end
			end
			
			BLUE: begin
				if(is_blue) begin
					data_out = {12'b0000_0000_1111};
				end
				else begin
					data_out = 12'b000000000000;
				end
			end
			default: data_out = 12'b000000000000;
			
		endcase	

	end
	
	
	assign colour_pixels = pixel_count;
	
	
endmodule
