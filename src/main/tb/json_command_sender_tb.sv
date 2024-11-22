`timescale 1ns / 1ps

module json_command_sender_tb;

    localparam CLKS_PER_BIT = 50_000_000/115_200;
    localparam BITS_N = 8;

    // Clock and reset signals
    logic clk;
    logic rst;
    logic [2:0] speed;
    logic uart_out;
    logic ready;

    // Instantiate the DUT (Device Under Test)
    forward #(
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .BITS_N(BITS_N),
    .NUM_BYTES(25)
    ) json_command (
        .clk(clk),
        .rst(rst),
        .speed(speed),
        .uart_out(uart_out),
        .ready(ready)
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
		
        // Set Speed
        speed = 3'b001;

        // End of simulation
        wait(ready) begin
			#50;
				$display("Transmission complete.");
            $finish;
        end
    end
	 
    // Monitor the UART output
    always @(posedge clk) begin
        if (!rst) begin
            $display("Sending byte: %h at time %t", json_command.current_byte, $time);
        end
    end

endmodule
