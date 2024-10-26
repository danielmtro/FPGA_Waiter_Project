module direction_fsm #(
    parameter FREQUENCY = 13,
	 parameter TOO_CLOSE = 8'd30
)(
    input           		  clk,
	 input logic [9:0] frequency_input, // frequency input
	 input logic [4:0] threshold_frequency,
	
    input logic [7:0] distance, // ultrasonic input
	 input logic [16:0] red_pixels,
	 input logic [16:0] threshold_pixels,
	 
    output [2:0] direction
);
	
	 logic red_stop_signal;
	 assign red_stop_signal = (red_pixels > threshold_pixels);
	 
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
	
	
	// create a shift register for the different microphone input values
	logic [9:0] mic_inputs [3:0];
	logic threshold_reached;
	
	// shift the values through the register
	always_ff @(posedge clk) begin
		if(frequency_input != frequency_input[0]) begin
			mic_inputs[3] <= mic_inputs[2];
			mic_inputs[2] <= mic_inputs[1];
			mic_inputs[1] <= mic_inputs[0];
			mic_inputs[0] <= frequency_input;
		end
	end
	
	// determine the thresholding reached status
	always_comb begin
		
		threshold_reached = (mic_inputs[0] >= threshold_frequency) &
								  (mic_inputs[1] >= threshold_frequency) &
								  (mic_inputs[2] >= threshold_frequency) &
								  (mic_inputs[3] >= threshold_frequency);
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

    // create a 1 second delay that can be used to prevent the robot 
    // from  instantly changing directions
    integer i = 0;
    localparam TIME_FOR_1s = 50000000;
    always_ff @(posedge clk) begin
        if(current_state != FORWARDS && current_state != BACKWARDS) begin
            i <= 0;
        end
        else if (i < TIME_FOR_1s) begin 
            i <= i + 1;
        end
    end

    state_type current_state = IDLE_BASE, next_state;

    // always_comb block for next state logic
    always_comb begin
        next_state = current_state;
			
		  case(current_state)
            IDLE_BASE : begin
                if(threshold_reached) begin
                    next_state = FORWARDS;
                end
            end
            IDLE_TABLE : begin
                if(threshold_reached) begin
                    next_state = BACKWARDS;
                end
            end
            FORWARDS : begin
                if((too_close && i >= TIME_FOR_1s) || (red_stop_signal)) begin // corresponds to two seconds at 50MHz
                    next_state = IDLE_TABLE;
                end
            end
            BACKWARDS : begin
                if(too_close && i >= TIME_FOR_1s) begin
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