module filter_select(
	input logic 			clk,
	input logic 			reset,
	input logic [1:0] 	freq_flag,
	input logic [1:0] 	filter_num,
	
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
	output logic 			valid_out //accomodates for 4 flags


);

	logic bri_ready_in, inv_ready_in, blur_ready_in, edge_ready_in;
	logic bri_ready_out, inv_ready_out, blur_ready_out, edge_ready_out;
	logic bri_sop_out, inv_sop_out, blur_sop_out, edge_sop_out;
	logic bri_eop_out, inv_eop_out, blur_eop_out, edge_eop_out;
	logic bri_valid_out, inv_valid_out, blur_valid_out, edge_valid_out;
	logic [11:0] inv_data, blur_data, bri_data, edge_data;
	
	
	
	
	enum logic [1:0] {
        COLOUR = 2'b00,
        BLUR = 2'b01,
        BRIGHTNESS = 2'b10,
        EDGES = 2'b11
    }state_type;

	

	inversion_filter inv_filt(
		.clk(clk),
		.reset(reset),
		.freq_flag(freq_flag),
		
		.data_in(data_in),
		.sop_in(sop_in),
		.eop_in(eop_in),
		.valid_in(valid_in),
		.ready_in(inv_ready_in),
		
		.ready_out(inv_ready_out),
		.data_out(inv_data),
		.sop_out(inv_sop_out),
		.eop_out(inv_eop_out),
		.valid_out(inv_valid_out)
	 );
	 
	 brightness_filter bright_filt(
		.clk(clk),
		.reset(reset),
		.freq_flag(freq_flag),
		
		.data_in(data_in),
		.sop_in(sop_in),
		.eop_in(eop_in),
		.valid_in(valid_in),
		.ready_in(bri_ready_in),
		
		.ready_out(bri_ready_out),
		.data_out(bri_data),
		.sop_out(bri_sop_out),
		.eop_out(bri_eop_out),
		.valid_out(bri_valid_out)	
	);
	
	blurring_filter blur_filt (
    .clk(clk),
    .freq_flag(freq_flag),  // Pitch input: 0 for 1x1, 1 for 3x3, 2 for 5x5
	 
    .ready_in(blur_ready_in),
	 .valid_in(valid_in),
	 .startofpacket_in(sop_in),
	 .endofpacket_in(eop_in),
	 .data_in(data_in),
	 
	 .ready_out(blur_ready_out),
	 .valid_out(blur_valid_out),
	 .startofpacket_out(blur_sop_out),
	 .endofpacket_out(blur_eop_out),
    .data_out(blur_data)
);

	edge_filter edge_filt(
		.clk(clk),
		.freq_flag(freq_flag),  // Pitch input: 0 for 1x1, 1 for 3x3, 2 for 5x5
		.ready_in(ready_in),
		.valid_in(valid_in),
		.startofpacket_in(sop_in),
		.endofpacket_in(eop_in),
		.data_in(data_in),
		.ready_out(edge_ready_out),
		.valid_out(edge_valid_out),
		.startofpacket_out(edge_sop_out),
		.endofpacket_out(edge_eop_out),
		.data_out(edge_data)
	);
	 
	 //depending on case, set appropriate enable HIGH
	 //for a specific filter
	 always_comb begin
		inv_ready_in 		= 0;
		blur_ready_in 		= 0;
		bri_ready_in 		= 0;
		edge_ready_in 		= 0;

		case (filter_num) 
			COLOUR		: begin 
				inv_ready_in 	= ready_in;
				
				ready_out		= inv_ready_out;
				sop_out			= inv_sop_out;
				eop_out			= inv_eop_out;
				valid_out		= inv_valid_out;
				data_out			= inv_data;
				end
			BLUR			: begin 
				blur_ready_in	= ready_in;
				
				ready_out		= blur_ready_out;
				sop_out			= blur_sop_out;
				eop_out			= blur_eop_out;
				valid_out		= blur_valid_out;
				data_out			= blur_data;
				end
			BRIGHTNESS 	: begin 
				bri_ready_in 	= ready_in;
				
				ready_out		= bri_ready_out;
				sop_out			= bri_sop_out;
				eop_out			= bri_eop_out;
				valid_out		= bri_valid_out;
				data_out			= bri_data;
				end
			EDGES			: begin
				edge_ready_in 	= ready_in;
				
				ready_out		= edge_ready_out;
				sop_out			= edge_sop_out;
				eop_out			= edge_eop_out;
				valid_out		= edge_valid_out;
				data_out		= edge_data;
				end
	 endcase
	end

	

endmodule 