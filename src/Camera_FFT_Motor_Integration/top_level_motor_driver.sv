module top_level_motor_driver (
    input wire CLOCK_50,
    output [17:0] LEDR,
	 output [7:0] LEDG,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    inout wire [35:0]GPIO, // GPIO5
	 input wire image_ready,

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

	// 
	//
	//
	// FFT STUFF IS PRESENTED BELOW
	//
	//
	//
	
	logic [9:0] mic_freq;
	logic fft_reset;
	assign fft_reset = ~SW[1]; //TODO change this to be image_ready
	FFT_top_level FFT_TL(
		.CLOCK_50(CLOCK_50),
		.reset(fft_reset),
		.I2C_SCLK(I2C_SCLK),
		.I2C_SDAT(I2C_SDAT),
		.AUD_ADCDAT(AUD_ADCDAT),
		.AUD_BCLK(AUD_BCLK),
		.AUD_XCK(AUD_XCK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.mic_freq(mic_freq)
	);
	
	// display threshold values on hex6 and hex7
	display_2digit  d2d(
    .clk(CLOCK_50),
    .value(tval),
    .display0(HEX6),
    .display1(HEX7)
	);

	// visualise pitch output
	display u_display (.clk(CLOCK_50),.value(mic_freq),.display0(HEX0),.display1(HEX1),.display2(HEX2),.display3(HEX3));

	
	//------------------------
	// MOTOR CONTROLCODE BELOW
	//------------------------
	
	
	// create a reset pulser
	logic reset_ultra;
	reset_pulser rp0 (
		.clock_50(CLOCK_50),
		.rst(reset_ultra)
	);
	
	// create sensor data
	// print sensor data on the hexs 4 and 5
	logic [7:0] distance;
	top_level_distance_sensor tlds (
		.CLOCK_50(CLOCK_50),
		.GPIO(GPIO),
		.enable(1'b1),
		.reset(reset_ultra),
		.ultrasonic_distance(distance),
		.HEX4(HEX4),
		.HEX5(HEX5)
	);
	
	// variables for handling drive control commands
	logic [3:0] direction;
	
	
	/*
	For reference: direction is an enum:
		IDLE_BASE, 	0	0000
      FORWARDS,	1	0001
		TURN,			2	0010
		TO_TABLE,	3	0011
      IDLE_TABLE,	4	0100
      BACKWARDS,	5	0101
		TURN_BACK,	6	0110
		RETURN_HOME,7	0111
      STOP			8	1000
	
	*/
	
	assign LEDG = direction;
	
	
	// THRESHOLD FREQUENCY ON SW[8:4]
	// display the current threshold value
	logic [4:0] tval;
	assign tval = SW[17:13];
	
	
	// DISPLAY THE THRESHOLDED FREQUENCY


	// start up the directional state machine
	
	// state machine for high level logic
	logic [16:0] red_pixel_threshold;
	assign red_pixel_threshold = 17'b01000000000000000;
	direction_fsm #(.TOO_CLOSE(8'd20)) dfsm (
		.clk(CLOCK_50),
		.frequency_input(mic_freq),
		.distance(distance),
		.reset(SW[6]),
		.threshold_frequency(tval),
		.direction(direction),	//direction output. refer to above
		.red_pixels(red_pixels),
		.green_pixels(green_pixels),
		.blue_pixels(blue_pixels),
		.threshold_pixels(red_pixel_threshold)
	);
	
	
	// speed control
	logic [2:0] speed;
	speed_fsm sfsm (
		.CLOCK_50(CLOCK_50),
		.direction(direction),
		.mic_freq(mic_freq),
		.threshold_frequency(tval),
		.speed(speed)
	);

	
	// actual motor control
	logic uart_out;
	drive_motor dm (
		.CLOCK_50(CLOCK_50),
		.direction(direction),
		.speed(speed),
		.uart_out(uart_out)
	);
	
	assign GPIO[5] = uart_out;
	
	
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
	wire clk_25_vga;
	
	camera_generation_top cgt0 (
	
	// Camera Inputs and Outputs
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
	.clk_25_vga(clk_25_vga)
);
	 

  logic [11:0] colour_data;
  logic [11:0] red_out;
  logic [11:0] green_out;
  logic [11:0] blue_out;
  logic [3:0] upper_thresh;
  logic [16:0] red_pixels;
  logic [16:0] green_pixels;
  logic [16:0] blue_pixels;
  
  /*
  Red: 1000 
  Blue: 
  */
  
  assign upper_thresh = 4'b1000; // can be changed to SW[5:2] for calibration
 
 // detects and outputs predominantly red pixels.
 // saves the number of pixels in red_pixels variable
  colour_detect red_detect(
	.clk(CLOCK_50),
	.data_in(rddata),
	.upper_thresh(upper_thresh),
	.address(rdaddress),
	.data_out(red_out),
	.colour(0),
	.colour_pixels(red_pixels),
	.sop(sop));
	
	// green colour detection
	colour_detect green_detect(
	.clk(CLOCK_50),
	.data_in(rddata),
	.upper_thresh(upper_thresh),
	.address(rdaddress),
	.data_out(green_out),
	.colour(1),
	.colour_pixels(green_pixels),
	.sop(sop));
	
	// green colour detection
	colour_detect blue_detect(
	.clk(CLOCK_50),
	.data_in(rddata),
	.upper_thresh(upper_thresh),
	.address(rdaddress),
	.data_out(blue_out),
	.colour(2),
	.colour_pixels(blue_pixels),
	.sop(sop));
	
	
	assign LEDR[16:0] = blue_pixels;

  // choose what data we are using
  logic decision;
  assign decision = SW[2];
  logic [11:0] display_data;
  
  assign display_data = (decision) ? blue_out : rddata;
  
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


endmodule