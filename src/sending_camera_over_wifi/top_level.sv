module top_level (
    input wire CLOCK_50,
    output [17:0] LEDR,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    inout wire [35:0]GPIO, // GPIO5

	// 7seg outputs

	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,

	// Microphone inputs and outputs
	output	     I2C_SCLK,
	inout		 I2C_SDAT,
	input		 AUD_ADCDAT,
	input    	 AUD_BCLK,
	output   	 AUD_XCK,
	input    	 AUD_ADCLRCK,
	
	// vga  outputs
	output wire VGA_HS,
	output wire VGA_VS,
	output wire [7:0] VGA_R,
	output wire [7:0] VGA_G,
	output wire [7:0] VGA_B,
	output wire VGA_BLANK_N,
	output wire VGA_SYNC_N,
	output wire VGA_CLK

);
	// Camera Inputs and Outputs
	wire ov7670_pclk; assign ov7670_pclk  = GPIO[21];
	wire ov7670_xclk; assign GPIO[20]     = ov7670_xclk;
	wire ov7670_vsync;assign ov7670_vsync = GPIO[23];
	wire ov7670_href; assign ov7670_href  = GPIO[22];
	wire [7:0] ov7670_data; assign ov7670_data  = GPIO[19:12];
	wire ov7670_sioc; assign GPIO[25]     = ov7670_sioc;
	wire ov7670_siod; assign GPIO[24]     = ov7670_siod;
	wire ov7670_pwdn; assign GPIO[10]     = ov7670_pwdn;
	wire ov7670_reset;assign GPIO[11]     = ov7670_reset;

	// vga outputs
	wire vga_hsync; assign VGA_HS 	      = vga_hsync;
	wire vga_vsync; assign VGA_VS 	      = vga_vsync;
	wire [7:0] vga_r; assign VGA_R		  = vga_r;
	wire [7:0] vga_g; assign VGA_G 		  = vga_g;
	wire [7:0] vga_b; assign VGA_B 		  = vga_b;
	wire vga_blank_N; assign VGA_BLANK_N  = vga_blank_N;
	wire vga_sync_N; assign VGA_SYNC_N	  = vga_sync_N;
	wire vga_CLK; assign VGA_CLK		  = vga_CLK;

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
	
	/*
	--------------------------------
	--------------------------------
	--------------------------------
	
	THE SECITON BELOW IS FOR THE CAMERA,
	BUFFER, ADDRESS GENERATOR AND VGA 
	INTERFACING 
	
	--------------------------------
	--------------------------------
	--------------------------------
	*/
	
	
	logic vga_ready, sop, eop;
	logic [16:0] rdaddress;
	logic [11:0] rddata;
	logic [11:0] red_pixels;
	wire clk_25_vga;
	

	logic [11:0] temp_pixel;
	logic write_enable;
	assign write_enable = SW[3];

	camera_generation_top cgt0 (
	
	// Camera Inputs and Outputs
	.write_enable(write_enable),
	.ov7670_pclk(ov7670_pclk),
	.ov7670_xclk(ov7670_xclk),
	.ov7670_vsync(ov7670_vsync),
	.ov7670_href(ov7670_href),
	.ov7670_data(ov7670_data),
	.ov7670_sioc(ov7670_sioc),
	.ov7670_siod(ov7670_siod),
	.ov7670_pwdn(ov7670_pwdn),
	.ov7670_reset(ov7670_reset),
	
	.clk_50(CLOCK_50),
	.SW(SW),	// switches taken as inputs	
	.ready(vga_ready), // ready comes from vga or its high - create selection
	.sop(sop),
	.eop(eop),
	.pixel(rddata),
	.address(rdaddress),
	.clk_25_vga(clk_25_vga),

	// section to read from second frame buffer
	.retrieve_address(equivalent_address),
	.output_data(temp_pixel));

  // choose what data we are using
  logic [11:0] display_data;
  
  assign display_data =  rddata;

  // in case we want to interface with the vga
  vga_interface vgai0 (
			 .clk_clk(clk_25_vga),                                         //                                       clk.clk
			 .reset_reset_n(1'b1),                                   //                                     reset.reset_n
			 .video_scaler_0_avalon_scaler_sink_startofpacket(sop), //         video_scaler_0_avalon_scaler_sink.startofpacket
			 .video_scaler_0_avalon_scaler_sink_endofpacket(eop),   //                                          .endofpacket
			 .video_scaler_0_avalon_scaler_sink_valid(1'b1),         //                                          .valid
			.video_scaler_0_avalon_scaler_sink_ready(vga_ready),         //                                          .ready
		   .video_scaler_0_avalon_scaler_sink_data(display_data),          //                                          .data
			.video_vga_controller_0_external_interface_CLK(vga_CLK),   // video_vga_controller_0_external_interface.CLK
			.video_vga_controller_0_external_interface_HS(vga_hsync),    //                                          .HS
			.video_vga_controller_0_external_interface_VS(vga_vsync),    //                                          .VS
			.video_vga_controller_0_external_interface_BLANK(vga_blank_N), //                                          .BLANK
			.video_vga_controller_0_external_interface_SYNC(vga_sync_N),  //                                          .SYNC
		   .video_vga_controller_0_external_interface_R(vga_r),     //                                          .R
		   .video_vga_controller_0_external_interface_G(vga_g),     //                                          .G
		   .video_vga_controller_0_external_interface_B(vga_b)      //                                          .B
	);

	logic [16:0] address;
	logic [11:0] pixel;

	// stuff for sending over wifi
	logic [11:0] start_pixel;
	assign start_pixel = 12'b000000001010;
	
	// create an image to send
	localparam num_pixels = 320 * 240;


	// Convert to an equivalent pixel
	logic [16:0] equivalent_address;
	assign equivalent_address = (address == 0) ? 0 : address - 1;

	always_ff @(posedge CLOCK_50) begin
		pixel <= (address == 0) ? start_pixel : temp_pixel;
	end

	logic image_uart;
	assign GPIO[1] = image_uart;

	image_sender #(.NUM_PIXELS(num_pixels),
				   .TIME_DELAY(62000),
				   .BAUD_RATE(115200)) is0 (
        .clk(CLOCK_50),
        .rst(edge_detect_keys[0]),
        .pixel(pixel),
        .address(address),
        .uart_out(image_uart),
        .image_ready(image_ready));
//	assign LEDR[16:0] = equivalent_address;

endmodule