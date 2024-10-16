module top_level_motor_driver (
    input wire CLOCK_50,
    output [17:0] LEDR,
    input wire [17:0]SW,
    input wire [3:0]KEY,
    inout wire [35:0]GPIO, // GPIO5

	// Microphone inputs and outputs
	output	     I2C_SCLK,
	inout		 I2C_SDAT,
	input		 AUD_ADCDAT,
	input    	 AUD_BCLK,
	output   	 AUD_XCK,
	input    	 AUD_ADCLRCK
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

	// 
	//
	//
	// FFT STUFF IS PRESENTED BELOW
	//
	//
	//

	localparam W        = 16;   //NOTE: To change this, you must also change the Twiddle factor initialisations in r22sdf/Twiddle.v. You can use r22sdf/twiddle_gen.pl.
  	
	localparam NSamples = 1024; //NOTE: To change this, you must also change the SdfUnit instantiations in r22sdf/FFT.v accordingly.

	logic adc_clk; adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
	logic i2c_clk; i2c_pll i2c_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz clock

	set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));

	dstream #(.N(W))                audio_input ();
  	dstream #(.N($clog2(NSamples))) pitch_output ();
	 
	mic_load #(.N(W)) u_mic_load (
  	 .adclrc(AUD_ADCLRCK),
	 .bclk(AUD_BCLK),
	 .adcdat(AUD_ADCDAT),
   	 .sample_data(audio_input.data),
	 .valid(audio_input.valid)
  );
			
	assign AUD_XCK = adc_clk;
	
  	fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
	    .clk(adc_clk),
		 .audio_clk(AUD_BCLK),
		 .reset(~SW[1]),
		 .audio_input(audio_input),
		 .pitch_output(pitch_output)
   );

	logic [2:0] fft_speed;
	logic [2:0] speed;
	assign speed = fft_speed + 1; // increase fft speed by one so we aren't stationary
	// Use a synchroniser to avoid metastable regions in clock domain crossing
   nbit_synchroniser #(.N(3)) nbs1(.clk(CLOCK_50),
									.x_valid(pitch_output.valid),
									.x(pitch_output.data[2:0]),
									.y(fft_speed));

	// visualise pitch output
	assign LEDR[9:0] = pitch_output.data;
	
	//
	//
	//
	// MOTOR CONTROLCODE BELOW
	//
	//
	//

	logic back_uart_out;
	logic forward_uart_out;
	logic stop_uart_out;
	logic [1:0]direction;
	logic uart_out;

	direction_fsm dfsm (
		.clk(CLOCK_50),
		.button_edge_0(edge_detect_keys[0]),
		.button_edge_1(edge_detect_keys[1]),
		.button_edge_2(edge_detect_keys[2]),
		.direction(direction)
	);
	
	// create reset signals
	logic f_rst, b_rst, s_rst;
	
	continous_motor_control cmc (
		.clk(CLOCK_50),
		.direction(direction),
		.forward_rst(f_rst),
		.reverse_rst(b_rst),
		.stop_rst(s_rst)
	);
	
	
	forward fward (
		 .clk(CLOCK_50),
		 .rst(f_rst),
		 .speed(speed),
		 .uart_out(forward_uart_out),
		 .ready()
	);
	
	backwards back (
		 .clk(CLOCK_50),
		 .speed(speed),
		 .rst(b_rst),
		 .uart_out(back_uart_out),
		 .ready()
	);
	
	stop stop_sequence (
		.clk(CLOCK_50),
		.rst(s_rst),
		.uart_out(stop_uart_out),
		.ready()
	);
	
	// always comb block to select what direction we want the robot to go
	always_comb begin
		
		if(direction == 2'b00) 
			begin
				uart_out = forward_uart_out;
			end
		else if (direction == 2'b01)
			begin
				uart_out = back_uart_out;
			end
		else
			begin
				uart_out = stop_uart_out;
			end
	end	
	
	assign GPIO[5] = uart_out;
	
	// view the current state
	assign LEDR[17] = direction[1];
	assign LEDR[16] = direction[0];

endmodule