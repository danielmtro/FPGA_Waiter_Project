module uart_tx_tb;

    // Testbench Parameters
    localparam CLK_PERIOD = 2; // 50 MHz clock (20ns period)
    localparam BITS_N = 8; // Number of data bits

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

    // DUT instantiation:
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT_115200),
        .BITS_N(BITS_N),
        .PARITY_TYPE(0) // Even parity
    ) dut_even_parity (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .valid_in(valid),
        .uart_out(uart_out_even_parity),
        .ready_out(ready_even_parity)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial #(MAX_TEST_CYCLES) $error("Test took too long! Is the ready signal never high?");

    // Test sequences
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        rst = 1;
        valid = 0;
        data_tx = 8'b00000000;

        // Release reset
        #(5 * CLK_PERIOD);
        rst = 0;

        repeat(RANDOM_TESTS) begin
            #(10 * CLK_PERIOD);
            send_data($urandom()&8'hFF, ready_even_parity);
        end
        // Test complete
        #(4000 * CLK_PERIOD);
		  #(1000 * CLK_PERIOD);
        $finish();
    end

    // Task to send data
    task send_data(input [BITS_N-1:0] data, input ready);
        begin
            if (ready) begin
              data_tx = data;
              valid = 1;
              #(CLK_PERIOD);
              valid = 0;
              wait(ready); // Wait until UART transmitter has finished.
            end
        end
    endtask

endmodule