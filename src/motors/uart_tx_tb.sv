`timescale 1ns / 1ps

module uart_tx_tb;

   // Parameters
   parameter CLKS_PER_BIT = (50_000_000/115_200);
   parameter BITS_N       = 8;

   // Inputs
   reg clk;
   reg rst;
   reg [BITS_N-1:0] data_tx;
   reg valid;

   // Outputs
   wire uart_out;
   wire ready;

   // Clock generation (50MHz)
   initial clk = 0;
   always #10 clk = ~clk; // 50MHz clock (20ns period)

   // Instantiate the UART TX module
   uart_tx #(
      .CLKS_PER_BIT(CLKS_PER_BIT),
      .BITS_N(BITS_N)
   ) uut (
      .clk(clk),
      .rst(rst),
      .data_tx(data_tx),
      .uart_out(uart_out),
      .valid(valid),
      .ready(ready)
   );

   // Test procedure
   initial begin
      // Initialize inputs
      rst = 1;
      valid = 0;
      data_tx = 8'b0;

      // Reset the design
      #100;
      rst = 0;

      // Wait for the UART module to be ready
      wait(ready == 1);
      
      // Test case 1: Transmit a byte (0x55)
      data_tx = 8'b01010101; // 0x55
      valid = 1;
      #40; // Wait for one clock cycle
      valid = 0;

      // Wait for the transmission to complete (stop bit and back to IDLE)
      wait(ready == 1);
      
      // Test case 2: Transmit another byte (0xA3)
      #80;
      wait(ready == 1);
      data_tx = 8'b10100011; // 0xA3
      valid = 1;
      #40; // Wait for one clock cycle
      valid = 0;

      // Wait for the transmission to complete
      wait(ready == 1);

      // Test case 3: Check for the edge cases
      // Transmit all 1s (0xFF)
      data_tx = 8'b11111111;
      valid = 1;
      #40;
      valid = 0;
      wait(ready == 1);

      // Transmit all 0s (0x00)
      #80;
      wait(ready == 1);
      data_tx = 8'b00000000;
      valid = 1;
      #40;
      valid = 0;
      wait(ready == 1);

      // Finish the simulation
      $finish;
   end

   // Monitor the UART output
   initial begin
      $monitor("Time: %0t | uart_out: %b | ready: %b | data_tx: %h", $time, uart_out, ready, data_tx);
   end

endmodule