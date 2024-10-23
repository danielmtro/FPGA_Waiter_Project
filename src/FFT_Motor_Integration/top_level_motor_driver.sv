module top_level_motor_driver (
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
	
	logic [9:0] mic_freq;
	logic fft_reset;
	assign fft_reset = ~SW[1];
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

//									
//	logic [2:0] fft_speed;
//	logic [2:0] speed;
//	assign fft_speed = mic_freq[2:0];
//	assign speed = fft_speed + 1; // increase fft speed by one so we aren't stationary
	
	// visualise pitch output
	display u_display (.clk(CLOCK_50),.value(mic_freq),.display0(HEX0),.display1(HEX1),.display2(HEX2),.display3(HEX3));

	
	//
	//
	//
	// MOTOR CONTROLCODE BELOW
	//
	//
	//
	
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
	logic [2:0] direction;
	
	
	// THRESHOLD FREQUENCY ON SW[8:4]
	// display the current threshold value
	logic [4:0] tval;
	assign tval = SW[17:13];
	
	
	// DISPLAY THE THRESHOLDED FREQUENCY

//	display tv_disp (.clk(CLOCK_50),
//						  .value(tval),
//						  .display0(HEX4),
//						  .display1(HEX5),
//						  .display2(HEX6),
//						  .display3(HEX7));

	// start up the directional state machine
	
	
	// state machine for high level logic
	direction_fsm #(.TOO_CLOSE(8'd20)) dfsm (
		.clk(CLOCK_50),
		.frequency_input(mic_freq),
		.distance(distance),
		.threshold_frequency(tval),
		.direction(direction)
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
	
	assign LEDR[2:0]  = speed;
	
	// actual motor control
	logic uart_out;
	drive_motor dm (
		.CLOCK_50(CLOCK_50),
		.direction(direction),
		.speed(speed),
		.uart_out(uart_out)
	);
	
	assign GPIO[5] = uart_out;
	
	// view the current state
	assign LEDR[17] = direction[2];
	assign LEDR[16] = direction[1];
	assign LEDR[15] = direction[0];
	

endmodule