module top_level_distance_sensor #(
    parameter CLOSE = 8'd50
) (
    input CLOCK_50,
    input enable,
    input reset,
    input echo,
    output trigger,
    output too_close
);

logic start;

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

// Always checks distance < 50cm, if true raises too_close
always_comb begin
  if (distance < CLOSE) begin
    too_close <= 1;
  end
  else begin
    too_close <= 1;
  end
end
endmodule