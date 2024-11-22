`timescale 1ns / 1ps

module motor_integration_tb;

    localparam ONE_MS = 50_000;

    localparam FREQUENCY = 13;
    localparam TOO_CLOSE = 8'd30;

    typedef enum logic [3:0] {
        IDLE_BASE = 4'b0000,
        FORWARDS,
		TURN,
		TO_TABLE,
        IDLE_TABLE,
        BACKWARDS,
		TURN_BACK,
		RETURN_HOME,
		TO_FACE,
        STOP
    } state_type;

    logic clk;
    logic rst;

    // Frequency Input
    logic [9:0] frequency_input;
    logic [4:0] threshold_frequency;

    // Ultrasonic Input
    logic [7:0] distance;

    // Pixel Input
    logic [16:0] red_pixels;
    logic [16:0] green_pixels;
    logic [16:0] blue_pixels;
    logic [16:0] threshold_pixels;

    // Output - direction
    logic [3:0] direction;
    direction_fsm #(
        .FREQUENCY(FREQUENCY),
        .TOO_CLOSE(TOO_CLOSE)
    ) chassis_movement (
        .clk(clk),
        .frequency_input(frequency_input),
        .threshold_frequency(threshold_frequency),
        .reset(rst),
        .distance(distance),
        .red_pixels(red_pixels),
        .green_pixels(green_pixels),
        .blue_pixels(blue_pixels),
        .threshold_pixels(threshold_pixels),
        .direction(direction)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();

        rst = 0;

        frequency_input = 0;
        threshold_frequency = 0;

        distance = 0;

        red_pixels = 0;
        green_pixels = 0;
        blue_pixels = 0;
        threshold_pixels = 0;

        direction = 0;

        #20;

        threshold_frequency = 5'b11000; // 24

        // 32768 pixels / 76800 pixels = 43% of all pixels
        threshold_pixels = 17'b01000000000000000; 

        rst = 1;
        #60;
        rst = 0;

        #20;
        frequency_input = 10'd12;
        #50000;
        frequency_input = 10'd48; // Double the value of the threshold

        wait(direction == FORWARDS);
        #(50000);

        frequency_input = 10'b0;
        blue_pixels = 17'd19200;
        #50000;
        blue_pixels = 17'd38400; // 50% of pixels

        wait(direction == TURN);
        #(50000);

        blue_pixels = 17'b0;
        green_pixels = 17'd19200;
        #50000;
        green_pixels = 17'd38400;

        wait(direction == TO_TABLE);
        #(50000);

        green_pixels = 17'b0;
        red_pixels = 17'd19200;
        #50000;
        red_pixels = 17'd38400;

        wait(direction == TO_FACE);
        #(20);

        red_pixels = 17'b0;

        wait(direction == IDLE_TABLE)
        #(50000);

        frequency_input = 10'd48;

        wait(direction == BACKWARDS);
        #(50000);

        frequency_input = 10'b0;
        green_pixels = 17'd38400;

        wait(direction == TURN_BACK);
        #(50000);

        green_pixels = 17'b0;
        blue_pixels = 17'd38400;

        wait(direction == RETURN_HOME);
        #(100);

        blue_pixels = 17'b0;

        // Check distance, must return to IDLE_BASE when distance < 30cm
        distance = 8'd50; // 50cm

        #50000;

        distance = 8'd40;

        #50000;

        distance = 8'd25;

        #50000;
    
        $display("Transmission complete.");

        $finish();
    end


endmodule