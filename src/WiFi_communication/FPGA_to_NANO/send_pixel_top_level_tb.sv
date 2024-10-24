module send_pixel_top_level_tb;

	parameter CLK_PERIOD = 2; // Baud rate = 115200, clock = 50 MHz
    parameter BITS_N = 8;
    parameter PARITY_TYPE = 0;

    // DUT Parameters
    localparam CLKS_PER_BIT = 434; // baud rate

	logic clk;
	
	logic GPIO_rx;
	logic GPIO_tx;
	logic [3:0] KEY;

	send_pixel_top_level #(
		.CLKS_PER_BIT((50000000/115200)), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
		.BITS_N(8), // Number of data bits per UART frame
		.PARITY_TYPE(0),  // 0 for none, 1 for odd parity, 2 for even.
		.IMAGE_SIZE(76800)
		)DUT(

		.CLOCK2_50(clk),
		
		.GPIO_rx(GPIO_rx),
		.GPIO_tx(GPIO_tx),
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
		
        // Release reset
        #(5 * CLK_PERIOD);
        KEY[0] = 1;
		
		#(10 * CLK_PERIOD);
        
        // Test case 1:
		// Send incorrect initial UART RX command
		simulate_uart_rx(8'h12);
		# (10 * CLK_PERIOD);

		// Send correct RX initialisation command
        simulate_uart_rx(8'h52);  // Send 0x52 (0100101 in binary)
        // Wait for TX to transmit
        #(20 * CLK_PERIOD);



		  #(11*CLK_PERIOD*CLKS_PER_BIT);
        
        // Test case 1: Simulate receiving data on UART RX (for example, sending 0xA5)
        simulate_uart_rx(8'h52);  // Send 0xA5 (10100101 in binary)

        // Wait for the RX to receive the data
        #(11*CLK_PERIOD*CLKS_PER_BIT);
		simulate_uart_rx(8'h52);  // Send 0xA5 (10100101 in binary)

		#(11*CLK_PERIOD*CLKS_PER_BIT);
		simulate_uart_rx(8'h52);  // Send 0xA5 (10100101 in binary)

		#(11*CLK_PERIOD*CLKS_PER_BIT);
		simulate_uart_rx(8'h52);  // Send 0xA5 (10100101 in binary)
		#(20*CLK_PERIOD*CLKS_PER_BIT);
		 
        $finish();
    end

	// Task to simulate serial data coming into UART RX (LSB first)
    task simulate_uart_rx(input [7:0] data);
        integer i;
        begin
            // Start bit (0)
            GPIO_rx = 1'b0;
            #(CLK_PERIOD*CLKS_PER_BIT); // Wait 1 bit period (approx 8680 ns for 115200 baud)

            // Send data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                GPIO_rx = data[i];
                #(CLK_PERIOD*CLKS_PER_BIT); // Wait 1 bit period
            end

            // Stop bit (1)
            GPIO_rx = 1'b1;
            #(CLK_PERIOD*CLKS_PER_BIT); // Wait 1 bit period
        end
    endtask
	 
endmodule
	 