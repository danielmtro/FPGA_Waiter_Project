module send_pixel_top_level_tb;

	localparam CLK_PERIOD = 2; // 50 MHz clock (20ns period)


	logic clk;
	
	logic [35:0] GPIO;
	logic [3:0] KEY;

send_pixel_top_level #(
	.CLKS_PER_BIT((50000000/115200)), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
   .BITS_N(8), // Number of data bits per UART frame
   .PARITY_TYPE(0),  // 0 for none, 1 for odd parity, 2 for even.
	.IMAGE_SIZE(76800)
	)DUT(

	.CLOCK2_50(clk),
	
	.GPIO(GPIO),
	.KEY(KEY)

);
	


	initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
	 
	 initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        KEY[0] = 0;
			KEY[1] = 0;
        // Release reset
        #(5 * CLK_PERIOD);
        KEY[0] = 1;
		  
		  
		  
		  #(5*CLK_PERIOD);
		  KEY[1] = 1;
		  #(5*CLK_PERIOD);
		  KEY[1] = 0;
        
        // Test complete
//		  #(8000 * CLK_PERIOD);
//		  #(8000 * CLK_PERIOD);
//		  #(8000 * CLK_PERIOD);
        #(600000 * CLK_PERIOD);
		  #(600000 * CLK_PERIOD);
		  #(8000 * CLK_PERIOD);
        $finish();
    end
	 
endmodule
	 