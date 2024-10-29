module debounce (
    input clk, button,
    output logic button_edge
);
  parameter delay_val = 2500; // 50us with clk period 20ns is 2500 counts
  integer count = 0;
  logic new_button_pressed=0;
  logic button_pressed = 0;

  always_ff @(posedge clk) begin : debouncing
      if (button != new_button_pressed) begin
        new_button_pressed <= button;
        count <= 0;
      end
      else if (count == delay_val) button_pressed <= new_button_pressed;
      else count <= count + 1;
  end

  logic button_q0;

  always_ff @(posedge clk) begin : edge_detect
      button_q0 <= button_pressed;
  end
  assign button_edge = (button_pressed > button_q0);
endmodule

