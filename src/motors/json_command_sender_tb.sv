`timescale 1ns / 1ps

module json_command_sender_tb;

    localparam CLKS_PER_BIT = 50_000_000/115_200;
    localparam BITS_N = 8;
    localparam NUM_BYTES = 25;

    // Clock and reset signals
    logic clk;
    logic rst;
    logic uart_out;
    logic ready;
    logic valid;

    // Instantiate the DUT (Device Under Test)
    json_command_sender #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .NUM_BYTES(NUM_BYTES))
    uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
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

        #50;
        valid = 1;
        // End of simulation
        wait(ready) begin
            $display("Transmission complete.");
            valid = 0;
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
