// Overall Top Level Module For Everything

/*
INFORMATION

SW[0] CONTROLS RESETTING THE CAMERA DO THIS IF:
	- THE IMAGE IS GREEN
	- THE IMAGE LOOKS ANY WAY WRONG

KEY[0] - KEY[3] CHOOSES THE FILTER
*/
module top_level(
	input wire clk_50,
	
	// GENERAL IO
	input wire [3:0] KEY,
	input wire [17:0]SW, // for resetting the camera on SW[0] and resetting FFT SW[1]
	output wire led_config_finished, // LED To let us know if reset is running
	
	// VGA inputs and outputs
	output wire vga_hsync,
	output wire vga_vsync,
	output wire [7:0] vga_r,
	output wire [7:0] vga_g,
	output wire [7:0] vga_b,
	output wire vga_blank_N,
	output wire vga_sync_N,
	output wire vga_CLK,
	
	// Camera Inputs and Outputs
	input wire ov7670_pclk,
	output wire ov7670_xclk,
	input wire ov7670_vsync,
	input wire ov7670_href,
	input wire [7:0] ov7670_data,
	output wire ov7670_sioc,
	inout wire ov7670_siod,
	output wire ov7670_pwdn,
	output wire ov7670_reset,
	
	// LCD Inputs and Outputs
	inout  wire [7:0] LCD_DATA,    // external_interface.DATA
   output wire       LCD_ON,      //                   .ON
   output wire       LCD_BLON,    //                   .BLON
   output wire       LCD_EN,      //                   .EN
   output wire       LCD_RS,      //                   .RS
   output wire       LCD_RW,      //                   .RW
	
	output [17:0] LEDR
);


	
	/*
	--------------------------------
	--------------------------------
	--------------------------------
	THE SECTION BELOW IS FOR THE CAMERA VISION STUFF
	INCLUDING FILTERS AND FILTER SELECTION
	--------------------------------
	--------------------------------
	--------------------------------
	*/

	
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
	
	.clk_50(clk_50),
	.SW(SW),	// switches taken as inputs	
	.ready(vga_ready), // ready comes from vga or its high - create selection
	.sop(sop),
	.eop(eop),
	.pixel(rddata),
	.address(rdaddress),
	.clk_25_vga(clk_25_vga)
);
	 

  logic [11:0] colour_data;
  logic [3:0] upper_thresh;
  logic [16:0] red_pixels;
  
  assign upper_thresh = 4'b1000; // can be changed to SW[5:2] for calibration
 
 // detects and outputs predominantly red pixels.
 // saves the number of pixels in red_pixels variable
  colour_detect cd0(
	.clk(clk_50),
	.data_in(rddata),
	.upper_thresh(upper_thresh),
	.address(rdaddress),
	.data_out(colour_data),
	.red_pixels(red_pixels),
	.sop(sop));
	
	assign LEDR[16:0] = red_pixels;

  // choose what data we are using
  logic decision;
  assign decision = SW[1];
  logic [11:0] display_data;
  
  assign display_data = (decision) ? colour_data : rddata;
  
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
