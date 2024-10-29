module direction_fsm #(
    parameter FREQUENCY = 13,
	 parameter TOO_CLOSE = 8'd30
)(
    input           		  clk,
	 input logic [9:0] frequency_input, // frequency input
    input logic [7:0] distance, // ultrasonic input
	 input logic [4:0] threshold_frequency,
    output [2:0] direction
);

	 // add a delay to the distance calculation
	 
	// create a distance shift register
	logic [7:0] distances [1:0];
	logic too_close;
	
	
	always_ff @(posedge clk) begin
		
		// process through shift register
		if(distance != distances[0]) begin
			distances[1] <= distances[0];
			distances[0] <= distance;
		end

	end
	
	// set a signal based on the data incoming
	always_comb begin
		if(distances[0] <= TOO_CLOSE && distances[1] <= TOO_CLOSE) begin
			too_close = 1'b1;
		end
		else begin
			too_close = 1'b0;
		end
	end
	

    // State typedef enum used here
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