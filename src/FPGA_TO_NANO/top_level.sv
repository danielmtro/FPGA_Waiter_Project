module top_level(
    input wire CLOCK_50,
    output [17:0] LEDR,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    inout wire [35:0]GPIO // GPIO5
);

    logic [3:0] debounced_keys;
	logic [3:0] edge_detect_keys;
	
	// debounce key
	genvar i;
	generate
		for(i = 0; i < 4; ++i) begin : debouncing_time
			debounce #(.DELAY_COUNTS(2500)) d_0 (
		   			  .clk(CLOCK_50),
						  .button(KEY[i]),
						  .button_pressed(debounced_keys[i])); 
		end : debouncing_time
	endgenerate
	
	
	// edging time
	
	genvar j;
	generate
		for(j = 0; j < 4; ++j) begin : edge_time
			edge_detect e0 (
					.clk(CLOCK_50),
					.button(~debounced_keys[j]),
					.button_edge(edge_detect_keys[j])
				);
		end : edge_time
	endgenerate  


    logic uart_out;
    assign GPIO[1] = uart_out;

    // create image sending variables
    logic [16:0] address;
    logic image_ready;
    logic [11:0] pixel;
	 
	logic [11:0] start_pixel;
	assign start_pixel = 12'b000000001010;
	
	// create an image to send
	localparam num_pixels = 320 * 240;
	 
	 
	 // -----------------------------------
	// ----------	Team Flag INITIIALISATION
	// -----------------------------------
	 
//    logic [11:0] image [num_pixels];
//	 initial begin
//		for (int i=0; i < num_pixels; i=i+1) begin
//			image[i] = (i > 24 && i < 75) ? 12'b1111_0000_0000 : 12'b0000_0000_1111;
//		end
//	 end

	
	// -----------------------------------
	// ----------	CHAD HO INITIIALISATION
	// -----------------------------------

	 (* ram_init_file = "chad-ho-320x240.mif" *)  logic [11:0]  image [0:num_pixels - 1];

	 // determine what the output pixel will be
	 logic [11:0]temp_pixel;
	 always_ff @(posedge CLOCK_50) begin
		temp_pixel <= image[address - 1];
	 end

	 always_ff @(posedge CLOCK_50) begin
		pixel <= (address == 0) ? start_pixel : temp_pixel;
	 end
	 
	 // --------------------------------------
	 // ------------------- NO MORE CHAD HO
	 // -----------------------------------
 	
	  // time_delay should correspond to the clock cycles 
	  // that should be waited after each pixel has been sent
    image_sender #(.NUM_PIXELS(num_pixels),
						 .TIME_DELAY(50000),
						 .BAUD_RATE(115200)) is0 (
        .clk(CLOCK_50),
        .rst(edge_detect_keys[0]),
        .pixel(pixel),
        .address(address),
        .uart_out(uart_out),
        .image_ready(image_ready)
    );
	 
	 assign LEDR[0] = image_ready;


endmodule