/*
State machine to control which filter is selected at a given point in time.
Module also includes debouncing and edge detection for the keys

    Here we map the followng
    KEY[0] -> Select Colour Filter
    KEY[1] -> Select Blur Filter
    KEY[2] -> Select Brightness Filter
    KEY[3] -> Select Edges Filter

Filter type is a 2 bit state output 
00: COLOUR
01: BLUR
10: BRIGHTNESS
11: EDGES
*/

module filter_fsm#(
  parameter DELAY_COUNTS = 2500     // Parameter for the debouncing module
)(
    input           		  clk,
    input        [3:0]        key,
    output logic [1:0]       filter_type
);

    // Stores the debounced signals and edge detect signals 
    logic [3:0] db;
	logic [3:0] edges;
	
	
	 genvar i;
	 generate 
		 // Debounce the key input
		 for(i=0; i<4; i++) begin  : debounce_keys
			  debounce #(.DELAY_COUNTS(DELAY_COUNTS)) d_i (.clk(clk),
																		  .button(key[i]),
																		  .button_pressed(db[i]));
		 end
	 endgenerate
	
		
	 genvar j;
	 generate
		 // edge detect all the key inputs
		 for(j = 0; j < 4; ++j) begin : edge_detect_keys
			  edge_detect e_i (.clk(clk),
									 .button(db[j]),
									 .button_edge(edges[j]));
    end
	 endgenerate


    // State teypedef enum used here
	 // Note that we specify the exact encoding that we want to use for each state
    typedef enum logic [1:0] {
        COLOUR = 2'b00,
        BLUR = 2'b01,
        BRIGHTNESS = 2'b10,
        EDGES = 2'b11
    } state_type;
    state_type current_state = COLOUR, next_state;

    // always_comb block for next state logic

    /*
    Here we map the followng
    KEY[0] -> Select Colour Filter
    KEY[1] -> Select Blur Filter
    KEY[2] -> Select Brightness Filter
    KEY[3] -> Select Edges Filter
    */
    always_comb begin
        next_state = current_state;

        if(edges[0] == 1'b1) begin
            next_state = COLOUR;
        end
        else if (edges[1] == 1'b1) begin
            next_state = BLUR;
        end
        else if (edges[2] == 1'b1) begin
            next_state = BRIGHTNESS;
        end
        else if (edges[3] == 1'b1) begin
            next_state = EDGES;
        end
        else begin
            next_state = current_state;
        end
    end

    // always_ff for FSM state variable flip_flops
    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    // assign outputs
    assign filter_type = current_state;

endmodule