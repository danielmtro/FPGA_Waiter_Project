module pixel_index_generator #(
    parameter NUM_PIXELS = 320 * 240,
	 parameter TIME_DELAY = 5000
)(
    input clk,
    input pixel_send_ready,
    input rst,
    output [16:0] address
);
	 
    logic delay_reached;
	 integer i = 0;
	
    logic [16:0] address_temp;
    always_ff @(posedge clk) begin 
        if(rst) begin 
            address_temp <= 0;
        end
        else begin

            // determine when we increment the address based on pixel ready signal
            // and additional delay
            if(pixel_send_ready && delay_reached) begin
                address_temp <= (address_temp == NUM_PIXELS) ? address_temp : address_temp + 1; // don't change if at the end
            end

        end
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            i <= 0;
        end
        else if(!(pixel_send_ready)) begin
            i <= 0;
        end
        else begin
            //count up to 5000 and reset if it doesn't get there
            if(i > TIME_DELAY) begin
                i <= 0; 
            end
            else begin
                i <= i + 1;
            end
        end
    end

    assign delay_reached = (i == TIME_DELAY) ? 1'b1 : 1'b0;
	 assign address = address_temp;

endmodule