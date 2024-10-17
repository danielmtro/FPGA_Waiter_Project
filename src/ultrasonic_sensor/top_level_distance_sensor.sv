
module top_level_distance_sensor (
    input CLOCK_50,
    input enable,
    input reset,
    inout [35:0] GPIO,
    output [7:0] distance
);

logic start;
logic echo, trigger;

assign echo = GPIO[34];
assign GPIO[35] = trigger;

// Measure the distance every 250ms
refresher250ms refresher_250ms (
  .clk(CLOCK_50),
  .en(enable),
  .measure(start)
);

// Sends trigger and reads distance
sensor_driver u0(
  .clk(CLOCK_50),
  .rst(reset),
  .measure(start),
  .echo(echo),
  .trig(trigger),
  .distance(distance)
);
endmodule