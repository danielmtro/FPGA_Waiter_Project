module direction_fsm #(
    parameter FREQUENCY = 13
)(
    input           		  clk,
	 input logic [9:0] frequency_input, // frequency input
    input logic too_close, // ultrasonic input
	 input logic [4:0] threshold_frequency,
    output [2:0] direction
);

	 // add a frequency delay to terms

    // State teypedef enum used here
	 // Note that we specify the exact encoding that we want to use for each state
    typedef enum logic [2:0] {
        IDLE_BASE = 3'b000,
        FORWARDS = 3'b001,
        IDLE_TABLE = 3'b010,
        BACKWARDS = 3'b011,
        STOP = 3'b100
    } state_type;

    // create a two second delay that can be used to prevent the robot 
    // from  instantly changing directions
    integer i = 0;
    localparam TIME_FOR_2s = 100000000;
    always_ff @(posedge clk) begin
        if(current_state != FORWARDS && current_state != BACKWARDS) begin
            i <= 0;
        end
        else if (i < TIME_FOR_2s) begin 
            i <= i + 1;
        end
    end

    state_type current_state = IDLE_BASE, next_state;

    // always_comb block for next state logic
    always_comb begin
        next_state = current_state;
			
		  case(current_state)
            IDLE_BASE : begin
                if(frequency_input > threshold_frequency) begin
                    next_state = FORWARDS;
                end
            end
            IDLE_TABLE : begin
                if(frequency_input > threshold_frequency) begin
                    next_state = BACKWARDS;
                end
            end
            FORWARDS : begin
                if(too_close && i >= TIME_FOR_2s) begin // corresponds to two seconds at 50MHz
                    next_state = IDLE_TABLE;
                end
            end
            BACKWARDS : begin
                if(too_close && i >= TIME_FOR_2s) begin
                    next_state = IDLE_BASE;
                end
            end
		  endcase
    end

    // always_ff for FSM state variable flip_flops
    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    // outputs
    assign direction = current_state;

endmodule