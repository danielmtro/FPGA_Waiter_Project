//module uart_rx_tx_tb();
//
//    // Parameters for simulation
//    parameter CLK_PERIOD = 2; // 50 MHz clock
//    parameter BITS_N = 8;
//    parameter PARITY_TYPE = 0;
//
//    // DUT Parameters
//    localparam CLKS_PER_BIT_115200 = 434; // Baud rate for 115200 baud
//    localparam RANDOM_TESTS = 5;
//    localparam MAX_TEST_CYCLES = (RANDOM_TESTS * 12 * CLKS_PER_BIT_115200) * 2;
//
//    // Testbench signals
//    logic clk;
//    logic rst;
//    logic [BITS_N-1:0] data_tx;
//    logic valid_in;
//    logic ready_in;
//    wire uart_out;
//    logic ready_out;
//    wire valid_out;
//    wire baud_trigger;
//
//    // Instantiate the UART TX module
//    uart_tx #(
//        .CLKS_PER_BIT(CLKS_PER_BIT_115200),
//        .BITS_N(BITS_N),
//        .PARITY_TYPE(PARITY_TYPE)
//    ) uart_tx_inst (
//        .clk(clk),
//        .rst(rst),
//        .data_tx(data_tx),
//        .valid_in(valid_in),
//        .ready_in(ready_in),
//        .uart_out(uart_out),
//        .ready_out(ready_out),
//		  .valid_out(valid_out),
//		  .baud_trigger(baud_trigger)
//    );
//
//    // Clock generation
//    initial begin
//        clk = 0;
//        forever #(CLK_PERIOD/2) clk = ~clk;
//    end
//
//    initial #(MAX_TEST_CYCLES) $error("Test took too long! Is the ready signal never high?");
//
//    // Simulation procedure
//    initial begin
//        $dumpfile("waveform.vcd");
//        $dumpvars();
//
//        // Initialize signals
//        rst = 1'b1;  // Assert reset
//        data_tx = 8'h00;
//        valid_in = 1'b0;
//        ready_in = 1'b0;
//
//        #(5 * CLK_PERIOD);
//        rst = 1'b0;  // Deassert reset
//        #(10 * CLK_PERIOD);
//
//        // Test case 1: Transmit data 0xA5
//        data_tx = 8'h52;
//        valid_in = 1'b1; // Signal valid input data
//        ready_in = 1'b0; // Assert ready from the receiver side
//		  rst = 1'b1;  // Assert reset
//
//        #(5 * CLK_PERIOD);
//        ready_in = 1'b1; // Assert ready from the receiver side
//        // Wait for the handshake to complete
//        @(posedge valid_out);
//        uart_tx_complete();  // Wait for UART TX to complete
//        $display("Test case 1 passed: Successfully transmitted 0xA5.");
//
//        // Deassert valid_in after transmission
//        ready_in = 1'b0;
//        valid_in = 1'b0;
//		  rst = 1'b0;  // Assert reset
//
//        // Test case 2: Transmit data 0x3C
//        #(20 * CLK_PERIOD);
//        data_tx = 8'h3C;
//        valid_in = 1'b1;
//		  rst = 1'b1;  // Assert reset
//
//        #(5*CLK_PERIOD)
//        ready_in = 1'b1;
//
//        @(posedge valid_out);
//        uart_tx_complete();  // Wait for UART TX to complete
//        $display("Test case 2 passed: Successfully transmitted 0x3C.");
//
//        #(4000 * CLK_PERIOD);
//        #(1000 * CLK_PERIOD);
//        $finish;
//    end
//
//    // Task to check for transmission completion
//    task uart_tx_complete();
//        begin
//            // Wait for UART to go through start, data, and stop bits
//            // This assumes a simple 10-bit frame: 1 start bit, 8 data bits, and 1 stop bit
//            #(10 * CLKS_PER_BIT_115200 * CLK_PERIOD);
//        end
//    endtask
//
//endmodule

module uart_rx_tx_tb();

    // Parameters for simulation
    parameter CLK_PERIOD = 2; // Baud rate = 115200, clock = 50 MHz
    parameter BITS_N = 8;
    parameter PARITY_TYPE = 0;

    // DUT Parameters
    localparam CLKS_PER_BIT_115200 = 434; // baud rate
    localparam RANDOM_TESTS = 5;
    localparam MAX_TEST_CYCLES = (RANDOM_TESTS * 12 * CLKS_PER_BIT_115200) * 2; // Should not take longer than 2x all random tests with 12 UART bits.

    // Testbench signals
    logic clk;
    logic rst;
    logic [BITS_N-1:0] data_tx;
    logic valid_out_rx;
    logic ready_even_parity;

    // UART RX input and data output
    logic gpio_rx;              // This simulates incoming serial data (RX)
    logic [BITS_N-1:0] data_rx; // Output data from UART RX
    logic parity_error;         // Parity error signal from UART RX
	 logic pixel_sent;
	 logic tx_alert;

    // Instantiate the UART RX module
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT_115200),
        .BITS_N(BITS_N),
        .PARITY_TYPE(PARITY_TYPE)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .uart_in(gpio_rx),       // Simulated RX input (serial data)
        .data_rx(data_rx),      // Received data output
        .ready_out(),
		  .valid_out(valid_out_rx),// Flag indicating data is ready
        .parity_error(parity_error), // Parity error detection
		  .pixel_sent(pixel_sent),
		  .tx_alert(tx_alert)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial #(MAX_TEST_CYCLES) $error("Test took too long! Is the ready signal never high?");

    // Simulation procedure
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        clk = 0;
        gpio_rx = 1'b1; // Default idle state for UART RX (high)
        rst = 1'b1;  // Assert reset
		  tx_alert = 1'b1;

		  #(5 * CLK_PERIOD);          // Hold reset for some time
		  rst = 1'b0;  // Deassert reset (ready to start)
		  tx_alert = 1'b0;

		  #(10 * CLK_PERIOD);
        
        // Test case 1: Simulate receiving data on UART RX (for example, sending 0xA5)
        simulate_uart_rx(8'h52);  // Send 0xA5 (10100101 in binary)

        // Wait for the RX to receive the data
        #(10 * CLK_PERIOD);
        if (valid_out_rx && data_rx == 8'h52) begin
            $display("Test case 1 passed: Successfully received 0xA5.");
        end else begin
            $display("Test case 1 failed: Did not receive correct data.");
        end

		  #(10 * CLK_PERIOD);
		  tx_alert = 1'b1;
		  
		  #(10 * CLK_PERIOD);
		  tx_alert = 1'b0;

		  #(20 * CLK_PERIOD);
        
        // Test case 1: Simulate receiving data on UART RX (for example, sending 0xA5)
        simulate_uart_rx(8'h52);  // Send 0xA5 (10100101 in binary)

        // Wait for the RX to receive the data
        #(10 * CLK_PERIOD);
        if (data_rx == 8'h52) begin
            $display("Test case 1 passed: Successfully received 0x52.");
        end else begin
            $display("Test case 1 failed: Did not receive correct data.");
        end		  
		  
		  
		  #(20 * CLK_PERIOD);

		  
        // Test case 2: Simulate receiving another byte (e.g., 0x3C)
        #(10 * CLK_PERIOD);
        simulate_uart_rx(8'h3C);  // Send 0x3C (00111100 in binary)

        // Wait for the RX to receive the data
        #(10 * CLK_PERIOD);
        if (data_rx == 8'h3C) begin
            $display("Test case 2 passed: Successfully received 0x3C.");
        end else begin
            $display("Test case 2 failed: Did not receive correct data.");
        end
		  
		  
		  #(10 * CLK_PERIOD);
		  tx_alert = 1'b0;

		  #(1000 * CLK_PERIOD);
        $finish;
    end

    // Task to simulate serial data coming into UART RX (LSB first)
    task simulate_uart_rx(input [7:0] data);
        integer i;
        begin
            // Start bit (0)
            gpio_rx = 1'b0;
            #(CLK_PERIOD*CLKS_PER_BIT_115200); // Wait 1 bit period (approx 8680 ns for 115200 baud)

            // Send data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                gpio_rx = data[i];
                #(CLK_PERIOD*CLKS_PER_BIT_115200); // Wait 1 bit period
            end

            // Stop bit (1)
            gpio_rx = 1'b1;
            #(CLK_PERIOD*CLKS_PER_BIT_115200); // Wait 1 bit period
        end
    endtask

endmodule

