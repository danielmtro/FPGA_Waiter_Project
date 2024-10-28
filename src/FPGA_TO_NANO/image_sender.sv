module image_sender #(
    parameter NUM_PIXELS = 10 * 10
)(
    input clk,
    input rst,
    input logic [11:0] pixel,
    output logic [16:0] address,
    output logic uart_out, 
    output logic image_ready
);

    logic [16:0] prev_address;

    // create the ready flag
    assign image_ready = address == NUM_PIXELS - 1;

    pixel_index_generator #(
        .NUM_PIXELS(NUM_PIXELS)      // test on the 3 x 3 image
    ) index_generator0 (
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

    logic new_pixel_signal;
    logic pixel_send_ready;

    pixel_sender #(.CLKS_PER_BIT(50_000_000/9600)) p_sender (
        .clk(clk),
        .rst(new_pixel_signal),
        .uart_out(uart_out),
        .ready(pixel_send_ready)
    );


endmodule