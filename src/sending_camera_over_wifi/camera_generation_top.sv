module camera_generation_top (
	
  input logic write_enable,
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
	
	input clk_50,
	input [17:0] SW,	// switches taken as inputs	
	input ready, // ready comes from vga or its high - create selection

	output sop,
	output eop,
	output [11:0] pixel,
	output [16:0] address,
	output clk_25_vga,

 input [16:0] retrieve_address,
 output [11:0] output_data
);


	wire btn_resend;
	assign btn_resend = SW[0];
	
	wire clk_50_camera;
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
    .wren(do_i_write));

  frame_buffer Inst_frame_buffer2(
    .rdaddress(retrieve_address),
    .rdclock(clk_50),
    .q(output_data),
    .wrclock(ov7670_pclk),
    .wraddress(wraddress[16:0]),
    .data(wrdata),
    .wren(do_i_write));
	
  logic [16:0] used_wr_address;
  assign used_wr_address = (do_i_write) ? wraddress[16:0] : 0;
 
  logic do_i_write;
  assign do_i_write = write_enable & wren;

  // create address generator
  address_generator ag0(
    .clk_25_vga(clk_25_vga),
    .resend(resend),
    .vga_ready(ready),
    .vga_start_out(sop),
    .vga_end_out(eop),
    .rdaddress(rdaddress)
  );
  
  assign pixel = rddata;
  assign address = rdaddress;

endmodule