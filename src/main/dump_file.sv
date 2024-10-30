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
	
	// Microphone inputs and outputs
	output	   I2C_SCLK,
	inout		 	I2C_SDAT,
	input		 	AUD_ADCDAT,
	input    	AUD_BCLK,
	output   	AUD_XCK,
	input    	AUD_ADCLRCK,
	
	// 7seg outputs
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	
	output [7:0] LEDG,
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

	logic valid;
	assign valid = 1'b1;

	
	/*
	--------------------------------
	--------------------------------
	--------------------------------
	
	THE SECTION BELOW IS FOR THE CAMERA,
	BUFFER, ADDRESS GENERATOR AND VGA 
	INTERFACING 
	
	--------------------------------
	--------------------------------
	--------------------------------
	*/
	wire btn_resend;
	assign btn_resend = SW[0];
	
	wire clk_50_camera;
	wire clk_25_vga;
	wire wren;
	wire resend;
	wire nBlank;
	wire vSync;
	wire [16:0] wraddress;
	wire [11:0] wrdata;
	logic [16:0] rdaddress;
	wire [11:0] rddata;
  	logic [11:0] vga_data;
	wire [7:0] red; wire [7:0] green; wire [7:0] blue;
	wire activeArea;

  my_altpll Inst_vga_pll(
      .inclk0(clk_50),
    .c0(clk_50_camera),
    .c1(clk_25_vga));

  assign resend =  ~btn_resend;

  ov7670_controller Inst_ov7670_controller(
      .clk(clk_50_camera),
    .resend(resend),
    .config_finished(led_config_finished),
    .sioc(ov7670_sioc),
    .siod(ov7670_siod),
    .reset(ov7670_reset),
    .pwdn(ov7670_pwdn),
    .xclk(ov7670_xclk));

  ov7670_capture Inst_ov7670_capture(
      .pclk(ov7670_pclk),
    .vsync(ov7670_vsync),
    .href(ov7670_href),
    .d(ov7670_data),
    .addr(wraddress),
    .dout(wrdata),
    .we(wren));
	
  frame_buffer Inst_frame_buffer(
    .rdaddress(rdaddress),
    .rdclock(clk_25_vga),
    .q(rddata),
    .wrclock(ov7670_pclk),
    .wraddress(wraddress[16:0]),
    .data(wrdata),
    .wren(wren));

  reg vga_ready, sop, eop;  

  // create address generator
  address_generator ag0(
    .clk_25_vga(clk_25_vga),
    .resend(resend),
    .vga_ready(vga_ready),
    .vga_start_out(sop),
    .vga_end_out(eop),
    .rdaddress(rdaddress)
  );
	 

  logic [11:0] colour_data;
  logic [3:0] upper_thresh;
  logic [16:0] red_pixels;
  
  assign upper_thresh = 4'b1000; // can be changed to SW[5:2] for calibration
  
	
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
	
	
	//-----------------------------------------------
	//standalone motor drive control using camera
	//colour detection and whistling
	//-----------------------------------------------
	
	logic image_ready;
	assign image_ready = SW[3];
	
	top_level_motor_driver motor_control_tl (
    .CLOCK_50(CLOCK_50),
    .LEDR(LEDR),
	 .LEDG(LEDG),
    .SW(SW),
    .KEY(KEY),
    .GPIO(GPIO), // GPIO5
	 .image_ready(image_ready),

	// 7seg outputs

	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),
	.HEX6(HEX6),
	.HEX7(HEX7),

	// Microphone inputs and outputs
	.I2C_SCLK(I2C_SCLK),
	.I2C_SDAT(I2C_SDAT),
	.AUD_ADCDAT(AUD_ADCAT),
	.AUD_BCLK(AUD_BCLK),
	.AUD_XCK(AUD_XCK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	
	// vga  outputs
	.VGA_HS(vga_hs),
	.VGA_VS(vga_vs),
	.VGA_R(vga_r),
	.VGA_G(cga_g),
	.VGA_B(cga_b),
	.VGA_BLANK_N(vga_blank_N),
	.VGA_SYNC_N(vga_sync_N),
	.VGA_CLK(vga_CLK)

);

endmodule
