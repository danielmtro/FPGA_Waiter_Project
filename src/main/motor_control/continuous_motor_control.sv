/*
This code allows for continuous commands to be send outwards
as opposed to temporary commands.

It will pulse reset for the activated controller
*/


module continous_motor_control
(
    input clk,
    input [3:0] direction, // should be a 3 bit state
    output forward_rst,
    output reverse_rst,
    output stop_rst,
	 output turn_rst,
	 output tb_rst
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

	 /*
	For reference: direction is an enum:
		IDLE_BASE, 	0	0000
      FORWARDS,	1	0001
		TURN,			2	0010
		TO_TABLE,	3	0011
      IDLE_TABLE,	4	0100
      BACKWARDS,	5	0101
		TURN_BACK,	6	0110
		RETURN_HOME,7	0111
      STOP			8	1000
	
	*/
	 
    always_comb begin
        
        forward_rst 	= 0;
        reverse_rst 	= 0;
        stop_rst 		= 0;
		  turn_rst 		= 0;
		  tb_rst 		= 0;

        case (direction) 
            4'b0001 : begin 
                forward_rst 	= (i%clks_per_100ms == 0) ? 1 : 0;
            end
				4'b0010 : begin
					 turn_rst 		= (i%clks_per_100ms == 0) ? 1 : 0;
				end
            4'b0011 : begin
                forward_rst 	= (i%clks_per_100ms == 0) ? 1 : 0;
            end
				4'b0101 : begin
					reverse_rst 	= (i%clks_per_100ms == 0) ? 1 : 0;
				end
				4'b0110 : begin
					tb_rst 			= (i%clks_per_100ms == 0) ? 1 : 0;
				end
				4'b0111 : begin
					reverse_rst 	= (i%clks_per_100ms == 0) ? 1 : 0;
				end
				4'b1000 : begin
                forward_rst 	= (i%clks_per_100ms == 0) ? 1 : 0;
            end
            default : begin
                stop_rst		= (i%clks_per_100ms == 0) ? 1 : 0;
            end
        endcase
    end

endmodule