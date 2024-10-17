/*
This code allows for continuous commands to be send outwards
as opposed to temporary commands.

It will pulse reset for the activated controller
*/


module continous_motor_control
(
    input clk,
    input [1:0] direction, // should be a 2 bit state
    output forward_rst,
    output reverse_rst,
    output stop_rst
);

    // create a counter to wait approx every 83.886 ms
    // assume a 50 Mhz clock
    integer i = 0;
    always_ff @(posedge clk) begin
        i <= i + 1;
    end

    // signals to determine frequency of reset pulsing
    logic [22:0] clks_per_100ms;
    assign clks_per_100ms = 1 << 22;

    always_comb begin
        
        forward_rst = 0;
        reverse_rst = 0;
        stop_rst = 0;

        case (direction) 
            2'b00 : begin 
                forward_rst = (i%clks_per_100ms == 0) ? 1 : 0;
            end
            2'b01 : begin
                reverse_rst = (i%clks_per_100ms == 0) ? 1 : 0;
            end
            2'b10 : begin
                stop_rst = (i%clks_per_100ms == 0) ? 1 : 0;
            end
        endcase
    end

endmodule