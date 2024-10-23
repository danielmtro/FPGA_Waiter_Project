module top_level_distance_sensor(
	input CLOCK_50,
	inout [35:0] GPIO,
   input enable,
	input reset,
	output [7:0] ultrasonic_distance,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7
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

logic [7:0] distance;
// Sends trigger and reads distance
sensor_driver u0(
  .clk(CLOCK_50),
  .rst(reset),
  .measure(start),
  .echo(echo),
  .trig(trigger), 
  .distance(distance)
);

 
 display dist_display (.clk(CLOCK_50),.value(distance),.display0(HEX4),.display1(HEX5),.display2(HEX6),.display3(HEX7));
 assign ultrasonic_distance = distance;
 
endmodule
