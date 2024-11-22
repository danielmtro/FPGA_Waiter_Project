module top_level(
	input CLOCK_50,
	inout [35:0] GPIO,
  input [17:0] SW,
	input [3:0] KEY,
	output [9:0] LEDR
);

logic start, reset;
logic echo, trigger;

assign echo = GPIO[34];
assign GPIO[35] = trigger;

// Reset button (KEY[3])
debounce reset_edge(
    .clk(CLOCK_50),
	  .button(!KEY[3]),
    .button_edge(reset)
);

// Measure the distance every 250ms
refresher250ms refresher_250ms (
  .clk(CLOCK_50),
  .en(SW[0]),
  .measure(start)
);

// Sends trigger and reads distance
sensor_driver u0(
  .clk(CLOCK_50),
  .rst(reset),
  .measure(start),
  .echo(echo),
  .trig(trigger), 
  .distance(LEDR)
);

  
endmodule
