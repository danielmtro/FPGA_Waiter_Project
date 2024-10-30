`timescale 1ns / 1ps

module image_sender_tb;

    localparam CLKS_PER_BIT = 50_000_000/9600;
    localparam BITS_N = 8;

    // Clock and reset signals
    logic clk;
    logic rst;
    logic uart_out;
    logic [11:0] pixel;
	 logic [16:0] address;
	 
	 // create an image to test with
    logic [11:0] image [3];
	 initial begin
		for (int i=0; i < 3; i=i+1) begin
			image[i] = (i > 1 && i < 3) ? 12'b1111_0000_0000 : 12'b0000_0000_1111;
		end
	 end

	 // assign the image based on the current address
	 assign pixel = image[address];

    // Instantiate the DUT (Device Under Test)
    logic image_ready;
	
    image_sender #(.NUM_PIXELS(3)) is0 (
        .clk(clk),
        .rst(rst),
        .pixel(pixel),
        .address(address),
        .uart_out(uart_out),
        .image_ready(image_ready)
    );
	 

    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk; // 50 MHz clock (20 ns period)

    // Simulation procedure
    initial begin

        // Apply reset
        rst = 1;
        #50;
        rst = 0;
		  
		  
        // End of simulation
        wait(image_ready) begin
				#50;
				$display("Transmission complete.");
            $finish;
        end

    end
	 
	 

    // Monitor the UART output
    always @(posedge clk) begin
        if (!rst) begin
            $display("Sending index: %d at time %t", address, $time);
        end
    end

endmodule