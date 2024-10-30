module image_sender #(
    parameter NUM_PIXELS = 320 * 240,
	 parameter TIME_DELAY = 5000,
	 parameter BAUD_RATE = 9600
)(
    input clk,
    input rst,
    input logic [11:0] pixel,
    output logic [16:0] address,
    output logic uart_out, 
    output logic image_ready
);

    logic [16:0] prev_address;
	logic new_pixel_signal;
    logic pixel_send_ready;

    // create the ready flag
    assign image_ready = address == NUM_PIXELS;

    pixel_index_generator #(
        .NUM_PIXELS(NUM_PIXELS),
		.TIME_DELAY(TIME_DELAY)
    ) index_generator0 (
        .clk(clk),
        .rst(rst),
        .pixel_send_ready(pixel_send_ready),
        .address(address)
    );

    small_image_pixel_index_generator #(
        .NUM_PIXELS(NUM_PIXELS),
		.TIME_DELAY(TIME_DELAY)
    ) small_image_index_generator0 (
        .clk(clk),
        .rst(rst),
        .pixel_send_ready(pixel_send_ready),
        .address(address)
    );

    // create a previous tracker to determine when we get a new pixel
    always_ff @(posedge clk) begin
        prev_address <= address;
    end

    // always_comb block to determine when we have a new address
    always_comb begin 
        if(rst) begin
            new_pixel_signal = 1'b1;
        end
        else if(prev_address != address) begin
            new_pixel_signal = 1'b1;
        end
        else begin
            new_pixel_signal = 1'b0;
        end
    end

    pixel_sender #(.CLKS_PER_BIT(50_000_000/BAUD_RATE)) p_sender (
        .clk(clk),
		  .pixel(pixel),
        .rst(new_pixel_signal),
        .uart_out(uart_out),
        .ready(pixel_send_ready)
    );


endmodule