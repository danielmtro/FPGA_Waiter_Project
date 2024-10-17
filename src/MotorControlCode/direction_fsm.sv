module direction_fsm(
    input           		  clk,
    input           		  button_edge_0, // controls sending the robot forwards
    input                 button_edge_1, // controls sending the robot backwards
	 input				     button_edge_2, // controls stopping the robot
    output                    [1:0] direction
);

    // State teypedef enum used here
	 // Note that we specify the exact encoding that we want to use for each state
    typedef enum logic [1:0] {
        FORWARDS = 2'b00,
        BACKWARDS = 2'b01,
		  STOP = 2'b10
    } state_type;

    state_type current_state = STOP, next_state;

    // always_comb block for next state logic
    always_comb begin
        next_state = current_state;
			
		  if(button_edge_2) begin
				next_state = STOP;
		  end
        else if(button_edge_0) begin
            next_state = FORWARDS;
        end
        else if(button_edge_1) begin
            next_state = BACKWARDS;
        end
    end

    // always_ff for FSM state variable flip_flops
    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    // outputs
    assign direction = current_state;

endmodule