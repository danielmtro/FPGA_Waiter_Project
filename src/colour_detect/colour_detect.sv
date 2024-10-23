`timescale 1ns / 1ps

module colour_detect #(
    parameter screen_percent = 80
    ) (
    input logic clk,
    input logic reset,

    input logic [11:0] data_in,
    
    input logic [3:0] upper_thresh,
    input logic [3:0] lower_thresh,

    input logic startofpacket,
    output logic flag_reached,
    output logic [16:0] colour_pixel_count_out
);
    
    // // Red
    // localparam [3:0] red_thresh = 4'b1000;

    // // Green
    // localparam [3:0] green_thresh = 4'b0011;

    // // Blue
    // localparam [3:0] blue_thresh = 4'b0011;

    // 320x240 image
    localparam image_width = 320;
    localparam image_length = 240;

    localparam total_pixels = image_width * image_length;

    localparam pixel_count_threshold = (total_pixels * screen_percent) / 100;

    reg [16:0] total_pixel_count;
    reg [16:0] colour_pixel_count;

    wire is_flag_colour;

    wire [3:0] red, green, blue;

    assign red = data_in[11:8];
    assign green = data_in[7:4];
    assign blue = data_in[3:0];


    logic flag1, flag2, flag3;
    always_comb begin
        flag1 = (green <= lower_thresh);
        flag2 = (blue <= lower_thresh);
        flag3 = (red >= upper_thresh);
        is_flag_colour = flag1 && flag2 && flag3;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            total_pixel_count <= 0;
            colour_pixel_count <= 0;
        end

        else begin
            if (startofpacket) begin
                total_pixel_count <= 0;
                colour_pixel_count <= 0;
            end
            else if (total_pixel_count < total_pixels) begin
                total_pixel_count <= total_pixel_count + 1;
                if (is_flag_colour)begin
                    colour_pixel_count <= colour_pixel_count + 1;
                end
            end
        end
    end
    
    always_ff @(posedge clk) begin
        colour_pixel_count_out = (total_pixel_count == total_pixels - 1) ? colour_pixel_count : colour_pixel_count_out;
    end

    assign flag_reached = (colour_pixel_count > pixel_count_threshold) ? 1'b1 : 1'b0;

endmodule