module top_level (
	input CLOCK_50,
	output	I2C_SCLK,
	inout		I2C_SDAT,
	input		AUD_ADCDAT,
	input   AUD_BCLK,
	output   AUD_XCK,
	input    AUD_ADCLRCK,
	output  logic [17:0] LEDR
);

	logic adc_clk; adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
	logic i2c_clk; i2c_pll i2c_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz clock

	set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));
		
	logic [15:0] data;
		
	mic_load #(.N(16)) u_mic_load (
    .adclrc(AUD_ADCLRCK),
	 .bclk(AUD_BCLK),
	 .adcdat(AUD_ADCDAT),
    .sample_data(data)
   );
	
	assign AUD_XCK = adc_clk;
		
	always_comb begin
		if (data[15]) LEDR[15:0] <= (~data[15:0]+1); // magnitude of a negative number (2's complement)
		else LEDR[15:0] <= data[15:0];
	end

endmodule
