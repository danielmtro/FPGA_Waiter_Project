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
    image_sender #(.NUM_PIXELS(3*3)) is0 (
        .clk(CLOCK_50),
        .rst(edge_detect_keys[0]),
        .pixel(pixel),
        .address(address),
        .uart_out(uart_out),
        .image_ready(image_ready)
    );

    // create an image to send
    logic [11:0] image [9];
	initial begin
		for (int i=0; i < 9; i=i+1) begin
			image[i] = (i > 2 && i < 6) ? 12'b1111_0000_0000 : 12'b0000_0000_1111;
		end
	end

    assign pixel = image[address];

endmodule