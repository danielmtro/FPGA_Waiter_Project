`timescale 1ns / 1ps

module json_command_sender_tb;

    localparam CLKS_PER_BIT = 50_000_000/115_200;
    localparam BITS_N = 8;

    // Clock and reset signals
    logic clk;
    logic rst;
    logic uart_out;
    logic ready;

    // Instantiate the DUT (Device Under Test)
    json_command_sender #(
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .BITS_N(BITS_N),
    .NUM_BYTES(25)
    ) uut (
        .clk(clk),
        .rst(rst),
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
		  
        // End of simulation
        wait(ready) begin
				#1000;
				rst = 1;
				#50;
				rst = 0;
        end
		  
		  wait (ready) begin
				#50;
				$display("Transmission complete.");
            $finish;
		  end
    end
	 
	 

    // Monitor the UART output
    always @(posedge clk) begin
        if (!rst) begin
            $display("Sending byte: %h at time %t", uut.current_byte, $time);
        end
    end

endmodule
