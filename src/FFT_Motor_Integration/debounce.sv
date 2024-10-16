/*
Debounce module debounces a given input.
Delay is set to 50 us (based on a 50 MHz clock)
*/

module debounce #(
  parameter DELAY_COUNTS = 2500     // For a 50MHz clock this is 50us and stuff
) (
    input clk, button,
    output reg button_pressed
);

  initial button_pressed = 0;

  // Use a synchronizer to synchronize `button`.
  wire button_sync; // Output of the synchronizer. Input to your debounce logic.
  synchroniser button_synchroniser (.clk(clk), .x(button), .y(button_sync));

  // Note: Use the synchronized `button_sync` wire as the input signal to the debounce logic.
  
  // Create a register for the delay counts
  reg [$clog2(DELAY_COUNTS):0] count = 0;
  reg prev_button = 0;

  // Set the count flip-flop:
  always @(posedge clk) begin
      if (button_sync != prev_button) begin
        count <= 0;
      end
      else if (count == DELAY_COUNTS) begin
        count <= count;
      end
      else begin
        count <= count + 1; 
      end
  end

  // Set the prev_button flip-flop:
  always @(posedge clk) begin
    if (button_sync != prev_button) begin
      prev_button <= button_sync;
    end
    else begin
      prev_button <= prev_button;
    end
  end

  // Set the button_pressed flip-flop:
  always @(posedge clk) begin
    if (button_sync == prev_button && count == DELAY_COUNTS) begin
      button_pressed <= prev_button;
    end
    else begin
      button_pressed <= button_pressed; 
    end
  end

endmodule

