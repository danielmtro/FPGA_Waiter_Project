module FFT_top_level(
	
	input CLOCK_50,
	input reset,
	
	// Microphone inputs and outputs
	output	     I2C_SCLK,
	inout		 I2C_SDAT,
	input		 AUD_ADCDAT,
	input    	 AUD_BCLK,
	output   	 AUD_XCK,
	input    	 AUD_ADCLRCK,
	
	output [9:0] mic_freq

);

	localparam W        = 16;   //NOTE: To change this, you must also change the Twiddle factor initialisations in r22sdf/Twiddle.v. You can use r22sdf/twiddle_gen.pl.
		
	localparam NSamples = 1024; //NOTE: To change this, you must also change the SdfUnit instantiations in r22sdf/FFT.v accordingly.

	logic adc_clk; adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
	logic i2c_clk; i2c_pll i2c_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz clock

	set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));

	dstream #(.N(W)) audio_input ();
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
		 .reset(reset),
		 .audio_input(audio_input),
		 .pitch_output(pitch_output)
	);

	
	// Use a synchroniser to avoid metastable regions in clock domain crossing
	nbit_synchroniser #(.N($clog2(NSamples))) nbs1(.clk(CLOCK_50),
									.x_valid(pitch_output.valid),
									.x(pitch_output.data),
									.y(mic_freq));

									
endmodule