module uart_tb();

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
    logic valid;
    logic uart_out_even_parity;
    logic ready_even_parity;

    // UART RX input and data output
    reg gpio_rx;              // This simulates incoming serial data (RX)
    wire [BITS_N-1:0] data_rx; // Output data from UART RX
    wire valid_out_rx;         // Data valid flag from UART RX
    wire parity_error;         // Parity error signal from UART RX

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
        .parity_error(parity_error) // Parity error detection
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
		  #(5 * CLK_PERIOD);          // Hold reset for some time
		  rst = 1'b0;  // Deassert reset (ready to start)

		  #(10 * CLK_PERIOD);
        // Test case 1: Simulate receiving data on UART RX (for example, sending 0xA5)
        simulate_uart_rx(8'hA5);  // Send 0xA5 (10100101 in binary)

        // Wait for the RX to receive the data
        #(10 * CLK_PERIOD);
        if (valid_out_rx && data_rx == 8'hA5) begin
            $display("Test case 1 passed: Successfully received 0xA5.");
        end else begin
            $display("Test case 1 failed: Did not receive correct data.");
        end

        // Test case 2: Simulate receiving another byte (e.g., 0x3C)
        #(10 * CLK_PERIOD);
        simulate_uart_rx(8'h3C);  // Send 0x3C (00111100 in binary)

        // Wait for the RX to receive the data
        #(10 * CLK_PERIOD);
        if (valid_out_rx && data_rx == 8'h3C) begin
            $display("Test case 2 passed: Successfully received 0x3C.");
        end else begin
            $display("Test case 2 failed: Did not receive correct data.");
        end

        #(4000 * CLK_PERIOD);
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
