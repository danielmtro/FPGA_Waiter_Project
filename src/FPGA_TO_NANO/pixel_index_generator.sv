module pixel_index_generator #(
    parameter NUM_PIXELS = 320 * 240
)(
    input clk,
    input pixel_send_ready,
    input rst,
    output [16:0] address
);

    always_ff @(posedge clk) begin 
        if(rst) begin 
            address <= 0;
        end
        else begin

            // determine when we increment the address based on pixel ready signal
            // and additional delay
            if(pixel_send_ready && delay_reached) begin
                address <= (address == NUM_PIXELS - 1) ? address : address + 1; // don't change if at the end
            end

        end
    end


    integer i;
    localparam TIME_DELAY = 5000;// 0.0001 second time delay
    always_ff @(posedge clk) begin
        if(rst) begin
            i <= 0;
        end
        else if(!(pixel_send_ready)) begin
            i <= 0;
        end
        else begin
            //count up to 5000 and reset if it doesn't get there
            if(i > 5000) begin
                i <= 0; 
            end
            else begin
                i <= i + 1;
            end
        end
    end

    logic delay_reached;
    assign delay_reached = (i == 5000) ? 1'b0 : 1'b1;

endmodule