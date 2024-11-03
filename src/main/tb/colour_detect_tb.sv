`timescale 1ns/1ps

module colour_detect_tb;

    // Inputs to the DUT
    reg clk;
    reg [11:0] data_in;
    reg [3:0] upper_thresh;
    reg [16:0] address;
    reg sop;
    reg [1:0] colour;

    // Outputs from the DUT
    wire [11:0] data_out;
    wire [16:0] colour_pixels;

    // Instantiate the colour_detect module
    colour_detect dut (
        .clk(clk),
        .data_in(data_in),
        .upper_thresh(upper_thresh),
        .address(address),
        .sop(sop),
        .colour(colour),
        .data_out(data_out),
        .colour_pixels(colour_pixels)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 20ns clock period (50 MHz)
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        data_in = 12'b0000_0000_0000;
        upper_thresh = 4'b1000;
        address = 0;
        sop = 1;
        colour = 2'b00;  // Start with RED

        // Dump the waveform to a VCD file for analysis
        $dumpfile("colour_detect_waveform.vcd");
        $dumpvars();

        // Reset the SOP and initialize the pixel count
        #20;
        sop = 0;
        address = 1;

        // Test for red detection: easy
        data_in = 12'b1111_0000_0000;  // Red-dominant
        #20;
        $display("Testing RED detection:");
        colour = 2'b00;  // Set color to RED
        #10;
        $display("Expected RED data_out = 1111_0000_0000, got %b", data_out);
        assert(data_out == 12'b1111_0000_0000) else $fatal("Red (easy) detection failed");

        #20;
        address = address + 1;

        // Test for red detection: medium
        data_in = 12'b1001_1000_0100;  
        #20;
        $display("Testing GREEN detection:");
        colour = 2'b00;  // Set color to RED
        #10;
        $display("Expected GREEN data_out = 0000_1111_0000, got %b", data_out);
        assert(data_out == 12'b1111_0000_0000) else $fatal("Red (medium) detection failed");

        #20;
        address = address + 1;

        // Test for red detection hard
        data_in = 12'b1011_1000_1010; 
        #20;
        $display("Testing BLUE detection:");
        colour = 2'b00;  // Set color to RED
        #10;
        $display("Expected BLUE data_out = 1111_0000_0000, got %b", data_out);
        assert(data_out == 12'b1111_0000_0000) else $fatal("Red (hard) detection failed");

        #20;
        address = address + 1;
		  
		  // Test for red detection where pixel is not red enough
        data_in = 12'b0100_0000_0000; 
        #20;
        $display("Testing BLUE detection:");
        colour = 2'b00;  // Set color to RED
        #10;
        $display("Expected BLUE data_out = 1111_0000_0000, got %b", data_out);
        assert(data_out == 12'b0000_0000_0000) else $fatal("No Red detection failed");

		  //display pixel count with expected number of pixels is 3
		  $display("Pixel count reset before SOP. Expected colour_pixels = 3, got %d", colour_pixels);
        assert(colour_pixels == 3) else $fatal("Pixel count did not reset on SOP");
		  
		  
        #20;
        address = address + 1;

        // Wrap around the color pixel counter with SOP signal
        sop = 1;
        #10;
        sop = 0;

        // Check that pixel count has reset
        $display("Pixel count reset after SOP. Expected colour_pixels = 0, got %d", colour_pixels);
        assert(colour_pixels == 0) else $fatal("Pixel count did not reset on SOP");

        // Final test with incremented address and color conditions
        data_in = 12'b1111_0000_0000;  // Red again
        upper_thresh = 4'h5;           // Lower threshold to detect more easily
        colour = 2'b00;                // Set to RED again
        #20;
        address = address + 1;

        $display("Final check for RED detection increment:");
        $display("Expected colour_pixels to increment, got %d", colour_pixels);
        assert(colour_pixels > 0) else $fatal("Pixel count did not increment");

        #10 $finish;
    end

endmodule
