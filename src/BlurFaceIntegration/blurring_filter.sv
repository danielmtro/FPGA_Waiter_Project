`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic ready,
    input logic valid,
    input logic startofpacket_in,
    input logic endofpacket_in,
    input logic [12-1:0] data_in,
    output logic [12-1:0] data_out
);
    // Extract RGB components from input data
    logic [3:0] red_in, green_in, blue_in;

    assign red_in   = data_in[11:8];  // Bits 11-8 for red
    assign green_in = data_in[7:4];   // Bits 7-4 for green
    assign blue_in  = data_in[3:0];   // Bits 3-0 for blue

    // 320x240 image
    localparam image_width = 9'b101000000;
    localparam image_length = 8'b11110000;

    logic [9:0] col_count;
    logic [8:0] row_count;

    logic head_detected;
    logic finish_blur;
    logic blur_pixels;
    logic face_ending;
    logic [9:0] blur_start, blur_end, temp_blur_start, temp_blur_end;

    // Image buffer for RGB components
    logic [3:0] red_buffer [0:(image_width*4 + 6)];
    logic [3:0] green_buffer [0:(image_width*4 + 6)];
    logic [3:0] blue_buffer [0:(image_width*4 + 6)];

    // Buffer counter to account for kernel output lag
    logic [11:0] buffer_counter;

    // Convolution filter and edge filters
    logic [9:0] conv_result_r, conv_result_g, conv_result_b;  // Final convolution results for RGB
    logic signed [9:0] TtoB_edge_result_r, TtoB_edge_result_g, TtoB_edge_result_b, 
        LtoR_edge_result_r, LtoR_edge_result_g, LtoR_edge_result_b; // Intermediray edge detection results
    logic signed [16:0] TtoB_grey_result, LtoR_grey_result;

    // Define the bitshift kernel_blur
    logic [3:0] kernel_blur [0:34];
    
    // Define the edge kernels
    logic [5:0] kernel_TtoB [0:24];
    logic [5:0] kernel_LtoR [0:24];

    // List of previous edges
    logic [5:0] dynamic_edge_logger;

    always_comb begin
    // Blur
        kernel_blur[0] = 0;
        kernel_blur[1] = 0;
        kernel_blur[2] = 1;
        kernel_blur[3] = 1;
        kernel_blur[4] = 1;
        kernel_blur[5] = 0;
        kernel_blur[6] = 0;

        kernel_blur[7] = 0;
        kernel_blur[8] = 1;
        kernel_blur[9] = 1;
        kernel_blur[10] = 2;
        kernel_blur[11] = 1;
        kernel_blur[12] = 1;
        kernel_blur[13] = 0;

        kernel_blur[14] = 15;
        kernel_blur[15] = 1;
        kernel_blur[16] = 2;
        kernel_blur[17] = 2;
        kernel_blur[18] = 2;
        kernel_blur[19] = 1;
        kernel_blur[20] = 15;

        kernel_blur[21] = 0;
        kernel_blur[22] = 1;
        kernel_blur[23] = 1;
        kernel_blur[24] = 2;
        kernel_blur[25] = 1;
        kernel_blur[26] = 1;
        kernel_blur[27] = 0;

        kernel_blur[28] = 0;
        kernel_blur[29] = 0;
        kernel_blur[30] = 1;
        kernel_blur[31] = 1;
        kernel_blur[32] = 1;
        kernel_blur[33] = 0;
        kernel_blur[34] = 0;

        /*
        Sum is 64
        Weights
        1 1 2 2 2 1 1
        1 2 2 4 2 2 1
        0 2 4 4 4 2 0
        1 2 2 4 2 2 1
        1 1 2 2 2 1 1
        */

    // Kernel for top to bottom edge detection
        kernel_TtoB[0] = 0;
        kernel_TtoB[1] = 1;
        kernel_TtoB[2] = 2;
        kernel_TtoB[3] = 1;
        kernel_TtoB[4] = 0;

        kernel_TtoB[5] = 0;
        kernel_TtoB[6] = 1;
        kernel_TtoB[7] = 1;
        kernel_TtoB[8] = 1;
        kernel_TtoB[9] = 0;

        kernel_TtoB[10] = 15;
        kernel_TtoB[11] = 15;
        kernel_TtoB[12] = 15;
        kernel_TtoB[13] = 15;
        kernel_TtoB[14] = 15;

        kernel_TtoB[15] = 1;
        kernel_TtoB[16] = 1;
        kernel_TtoB[17] = 1;
        kernel_TtoB[18] = 1;
        kernel_TtoB[19] = 1;

        kernel_TtoB[20] = 1;
        kernel_TtoB[21] = 1;
        kernel_TtoB[22] = 2;
        kernel_TtoB[23] = 1;
        kernel_TtoB[24] = 1;

        /*
        1  2  4  2  1
        1  2  2  2  1
        0  0  0  0  0
       -2 -2 -2 -2 -2
       -2 -2 -4 -2 -2
        */

    // Kernel for left to right edge detection
        kernel_LtoR[0] = 0;
        kernel_LtoR[1] = 0;
        kernel_LtoR[2] = 15;
        kernel_LtoR[3] = 1;
        kernel_LtoR[4] = 1;

        kernel_LtoR[5] = 1;
        kernel_LtoR[6] = 1;
        kernel_LtoR[7] = 15;
        kernel_LtoR[8] = 1;
        kernel_LtoR[9] = 1;

        kernel_LtoR[10] = 2;
        kernel_LtoR[11] = 1;
        kernel_LtoR[12] = 15;
        kernel_LtoR[13] = 1;
        kernel_LtoR[14] = 2;

        kernel_LtoR[15] = 1;
        kernel_LtoR[16] = 1;
        kernel_LtoR[17] = 15;
        kernel_LtoR[18] = 1;
        kernel_LtoR[19] = 1;

        kernel_LtoR[20] = 0;
        kernel_LtoR[21] = 0;
        kernel_LtoR[22] = 15;
        kernel_LtoR[23] = 1;
        kernel_LtoR[24] = 1;

        /*
        1  1  0 -2 -2
        2  2  0 -2 -2
        4  2  0 -2 -4
        2  2  0 -2 -2
        1  1  0 -2 -2
        */

    end

    // Shift incoming data into separate RGB buffers
    always_ff @(posedge clk) begin : Image_buffer
        if (startofpacket_in) begin
            row_count <= 0;
            col_count <= 0;
            buffer_counter <= 0;

            for (int i = 0; i < (image_width*4 + 6); i++) begin
                red_buffer[i] <= 0;
                green_buffer[i] <= 0;
                blue_buffer[i] <= 0;
            end
        end
		  
		  if (ready && valid) begin
            // Shift the buffers left for red, green, and blue
            for (int i = 0; i < (image_width*4 + 6); i++) begin
                red_buffer[i] <= red_buffer[i+1];
                green_buffer[i] <= green_buffer[i+1];
                blue_buffer[i] <= blue_buffer[i+1];
            end
            // Insert new data for each color component
            red_buffer[(image_width*4 + 6)] <= red_in;
            green_buffer[(image_width*4 + 6)] <= green_in;
            blue_buffer[(image_width*4 + 6)] <= blue_in;

            if (col_count == 319) begin
                col_count <= 0;
                row_count <= row_count + 1;
            end

            else begin
                col_count <= col_count + 1;
            end

        // Increment buffer counter until it is 4 rows and 6 pixels wide (320x4+6) to account for kernel lag
            if (buffer_counter < 1286) begin
                buffer_counter <= buffer_counter + 1;
            end
        end
    end

    // Blur images and detect edges
    always_ff @(posedge clk) begin : Convolution
        // Reset variables for every pixel
        conv_result_r = 0;
        conv_result_g = 0;
        conv_result_b = 0;
        
        TtoB_edge_result_r = 0;
        TtoB_edge_result_g = 0;
        TtoB_edge_result_b = 0;
        LtoR_edge_result_r = 0;
        LtoR_edge_result_g = 0;
        LtoR_edge_result_b = 0;

        TtoB_grey_result = 0;
        LtoR_grey_result = 0;

        // Reset variables at the start of a new image
        if ((row_count == 0) && (col_count == 0)) begin
            dynamic_edge_logger = 0;
            blur_start <= 9'b0010100010;
            blur_end <= 9'b0010100010;
            head_detected <= 0;
            finish_blur <= 0;
            temp_blur_start <= 0;
            temp_blur_end <= 0;
            blur_pixels = 0;
            face_ending <= 0;
        end

        // Convolute RGB
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 7; j++) begin
                conv_result_r = conv_result_r + (red_buffer[(i * image_width) + j] << kernel_blur[((7 * i) + j)]);
                conv_result_g = conv_result_g + (green_buffer[(i * image_width) + j] << kernel_blur[((7 * i) + j)]);
                conv_result_b = conv_result_b + (blue_buffer[(i * image_width) + j] << kernel_blur[((7 * i) + j)]);
            end
        end

        // Apply edge detection to RGB
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                // Top to bottom edge filter
                if (i < 3) begin
                    TtoB_edge_result_r = TtoB_edge_result_r + (red_buffer[(i * image_width) + j] << kernel_TtoB[((5 * i) + j)]);
                    TtoB_edge_result_g = TtoB_edge_result_g + (green_buffer[(i * image_width) + j] << kernel_TtoB[((5 * i) + j)]);
                    TtoB_edge_result_b = TtoB_edge_result_b + (blue_buffer[(i * image_width) + j] << kernel_TtoB[((5 * i) + j)]);
                end
                else begin
                    TtoB_edge_result_r = TtoB_edge_result_r - (red_buffer[(i * image_width) + j] << kernel_TtoB[((5 * i) + j)]);
                    TtoB_edge_result_g = TtoB_edge_result_g - (green_buffer[(i * image_width) + j] << kernel_TtoB[((5 * i) + j)]);
                    TtoB_edge_result_b = TtoB_edge_result_b - (blue_buffer[(i * image_width) + j] << kernel_TtoB[((5 * i) + j)]);
                end

                // Left to right edge filter
                if (j < 3) begin
                    LtoR_edge_result_r = LtoR_edge_result_r + (red_buffer[(i * image_width) + j] << kernel_LtoR[((5 * i) + j)]);
                    LtoR_edge_result_g = LtoR_edge_result_g + (green_buffer[(i * image_width) + j] << kernel_LtoR[((5 * i) + j)]);
                    LtoR_edge_result_b = LtoR_edge_result_b + (blue_buffer[(i * image_width) + j] << kernel_LtoR[((5 * i) + j)]);
                end
                else begin
                    LtoR_edge_result_r = LtoR_edge_result_r - (red_buffer[(i * image_width) + j] << kernel_LtoR[((5 * i) + j)]);
                    LtoR_edge_result_g = LtoR_edge_result_g - (green_buffer[(i * image_width) + j] << kernel_LtoR[((5 * i) + j)]);
                    LtoR_edge_result_b = LtoR_edge_result_b - (blue_buffer[(i * image_width) + j] << kernel_LtoR[((5 * i) + j)]);
                end
            end
        end

        // Convert edge data from RGB to greyscale
        TtoB_grey_result = (TtoB_edge_result_r << 5) // Multiply by 32
                            + (TtoB_edge_result_g << 6) // Multiply by 64
                            + (TtoB_edge_result_b << 4); // Multiply by 16
        
        LtoR_grey_result = (LtoR_edge_result_r << 5) // Multiply by 32
                            + (LtoR_edge_result_g << 6) // Multiply by 64
                            + (LtoR_edge_result_b << 4); // Multiply by 16

        if (ready && valid) begin
            // Wait for all data to pass through convolution
            if (buffer_counter < 1286) begin
                data_out <= 0;
            end

            // Update dynamic edge logger
            dynamic_edge_logger = dynamic_edge_logger << 1;

            if ((TtoB_grey_result > 0) || (LtoR_grey_result > 0)) begin
                dynamic_edge_logger = dynamic_edge_logger + 1;
            end

            else begin
                // Reset variables at the start of a new line
                if (col_count == 319) begin
                    if ((temp_blur_start != 0) && (temp_blur_end != 0)) begin
                        blur_start <= temp_blur_start;
                        blur_end <= temp_blur_end;
                    end

                    if ((head_detected) && (!face_ending))begin
                        blur_start <= temp_blur_start - 5;
                    end

                    temp_blur_start <= 0;
                    temp_blur_end <= 0;
                end

                // If a centrally loacted head is detected, raise a flag
                if (!head_detected) begin
                    // Not all edges are signs of a head, check that the edge is not noise, a horizontal or a
                    // vertical wall edge and that the head is reasonably central in the image (50% of the camera frame)
                    // For finding the start of the face, the toelrance is required to be reasonably strict in the dynamic edge logger
                    if (((dynamic_edge_logger % 2 == 0) && (dynamic_edge_logger < 25) && (dynamic_edge_logger > 10)) && ((col_count >= blur_start - 50) && (col_count <= blur_start + 50))) begin
                        head_detected <= 1;
                        blur_pixels = 1;
                        temp_blur_start <= col_count;
                        temp_blur_end <= col_count;
                    end

                    // For no blur, pass through the data
                    data_out <= {red_buffer[0], green_buffer[0], blue_buffer[0]};
                end

                // Check if blurring is finished or if pixels are within blurring bounds
                else begin
                    if (finish_blur) begin
                        // For no blur, pass through the data
                        data_out <= {red_buffer[0], green_buffer[0], blue_buffer[0]};
                    end

                    else begin
                        // Check if pixel is not within dynamic blurring boundary
                        if ((col_count < blur_start - 5) || (col_count > (blur_end + 5))) begin
                                // For no blur, pass through the data
                                data_out <= {red_buffer[0], green_buffer[0], blue_buffer[0]};
                                blur_pixels = 0;
                        end

                        // Blur face and check for edges on face
                        else begin
                            // Check that pixel is edge
                            // For finding the end of the face, the toelrance can be more flexible in the dynamic edge logger
                            if ((dynamic_edge_logger % 2 == 0) && (dynamic_edge_logger < 30) && (dynamic_edge_logger > 5)) begin
                                // Continuously check for the last edge in the image
                                if (blur_pixels) begin
                                    temp_blur_end <= col_count;

                                    // If the face start pixel begins to move to the right
                                    if (temp_blur_start > (blur_start + 5)) begin
                                            face_ending <= 1;
                                    end
                                end

                                // For first edge pixel on left side, raise a flag and set temp_blur_start
                                else begin
                                    temp_blur_start <= col_count;
                                    temp_blur_end <= col_count;
                                    blur_pixels = 1;
                                end
                            end

                            // Where face edge not detected properly, assume face broadens out at 22.5 degrees
                            if (!face_ending) begin
                                if ((col_count > (blur_start + 10)) && (temp_blur_start == 0)) begin
                                    if (col_count % 2 == 0) begin
                                            temp_blur_start <= blur_start - 1;
                                            blur_pixels = 1;
                                    end
                                    else begin
                                            temp_blur_start <= blur_start;
                                            blur_pixels = 1;
                                    end
                                end

                                if ((col_count > (blur_end + 10)) && (temp_blur_end == 0)) begin
                                    if (col_count % 2 == 0) begin
                                            temp_blur_end <= blur_end + 1;
                                            blur_pixels = 0;
                                    end
                                    else begin
                                            temp_blur_end <= blur_end;
                                            blur_pixels = 0;
                                    end
                                end
                            end

                            // If the face is ending, where face edge not detected properly, slowly narrow down until face is finished
                            if (face_ending) begin
                                if (temp_blur_start < blur_start) begin
                                    if (col_count % 2 == 0) begin
                                            temp_blur_start <= blur_start + 1;
                                    end
                                    else begin
                                            temp_blur_start <= blur_start;
                                    end
                                end

                                if ((temp_blur_end > blur_end) || (temp_blur_end < blur_end - 10)) begin
                                    if (col_count % 2 == 0) begin
                                            temp_blur_end <= blur_end - 1;
                                    end
                                    else begin
                                            temp_blur_end <= blur_end;
                                    end
                                end

                                if (blur_end - blur_start <= 5) begin
                                    finish_blur <= 1;
                                end
                            end
                        end
                    end
                end

                // Blur the pixels
                if (blur_pixels) begin
                    // Remove noise from background in blur
                    if ((conv_result_r[9:6] > 10) && (conv_result_g[9:6] > 10) && (conv_result_b[9:6] > 10)) begin
                        conv_result_r[9:6] = (conv_result_r[9:6]+red_buffer[0]) >> 1;
                        conv_result_g[9:6] = (conv_result_g[9:6]+red_buffer[0]) >> 1;
                        conv_result_b[9:6] = (conv_result_b[9:6]+red_buffer[0]) >> 1;
                    end
                    // Combine the normalized results for each color component
                    data_out <= {conv_result_r[9:6], conv_result_g[9:6], conv_result_b[9:6]};
                end
                
                // Output the input pixel
                else begin
                    // For no blur, pass through the data
                    data_out <= {red_buffer[0], green_buffer[0], blue_buffer[0]};
                end
            end
        end
    end

endmodule