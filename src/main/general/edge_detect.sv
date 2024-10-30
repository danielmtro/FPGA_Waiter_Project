/*
Module acts a a positive edge detection.
It will take in an input signal and will output a logic
value corresponding to whether or not there was a positive
edge change in the last clock cycle.
*/

module edge_detect(
    input           		  clk,
    input           		  button,
    output                button_edge
);

    // Rising edge detection block here!
    logic button_q0 = 0;
    always_ff @(posedge clk) begin : edge_detect
        button_q0 <= button;
    end : edge_detect
    assign button_edge = (button > button_q0);

endmodule