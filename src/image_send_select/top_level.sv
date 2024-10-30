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

	// pixel variables
	logic [11:0] red_pixel;
	logic [11:0] blue_pixel;
    logic [11:0] pixel;
	 
	 logic [11:0] start_pixel;
	 assign start_pixel = 12'b000000001010;
	 
	 // create an image to send
	 localparam num_pixels = 10 * 10;
	 
	// create a completely red image
   logic [11:0] red_image [num_pixels];
	 initial begin
		for (int i=0; i < num_pixels; i=i+1) begin
			red_image[i] = 12'b1111_0000_0000;
		end
	 end

	// create a completely blue image
	logic [11:0] blue_image [num_pixels];
	 initial begin
		for (int i=0; i < num_pixels; i=i+1) begin
			blue_image[i] = 12'b0000_0000_1111;
		end
	 end

	
	// -----------------------------------
	// ----------	CHAD HO INITIIALISATION
	// -----------------------------------

	//  (* ram_init_file = "chad-ho-320x240.mif" *)  logic [11:0]  image [0:num_pixels - 1];

	 // determine what the output pixel will be
	 logic [11:0] temp_red_pixel;
	 logic [11:0] temp_blue_pixel;
	 always_ff @(posedge CLOCK_50) begin
		temp_red_pixel <= red_image[address - 1];
		temp_blue_pixel <= blue_image[address - 1];
	 end

	 always_ff @(posedge CLOCK_50) begin
		red_pixel <= (address == 0) ? start_pixel : temp_red_pixel;
		blue_pixel <= (address == 0) ? start_pixel : temp_blue_pixel;
	 end
	 



	 // --------------------------------------
	 // ------------------- NO MORE CHAD HO
	 // -----------------------------------
 	
	// Image selection mode

	logic [3:0] state;

	localparam TABLE_STATE = 4'b0100;
	localparam ONE_SECOND_DELAY = 50_000_000;

	always_comb begin
		state = (SW[0]) ? TABLE_STATE : 4'b0;
	end
	
	logic reset_signal;
	image_send_select #(
		.WAIT_TIME(ONE_SECOND_DELAY * 5),
		.RESET_TIME(ONE_SECOND_DELAY),
		.TABLE_STATE(TABLE_STATE)
		) iss0 (
		.clk(CLOCK_50),
		.norm_in(blue_pixel),
		.blur_in(red_pixel),

		.state(state),// not hard coded but corresponding to SW[3:0]
		.image_ready(image_ready),

		.out_state(LEDR[3:0]),
		.reset_signal(reset_signal),
		.data_out(pixel)
	);



	  // time_delay should correspond to the clock cycles 
	  // that should be waited after each pixel has been sent
    image_sender #(.NUM_PIXELS(num_pixels),
						 .TIME_DELAY(49000),
						 .BAUD_RATE(115200)) is0 (
        .clk(CLOCK_50),
        .rst(SW[1]),
        .pixel(pixel),
        .address(address),
        .uart_out(uart_out),
        .image_ready(image_ready)
    );

	assign LEDR[4] = image_ready;

    

endmodule