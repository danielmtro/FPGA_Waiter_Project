`timescale 1ns/1ps

module colour_detect_tb;
    
    // Inputs
    logic clk;
    logic reset;
    logic [11:0] data_in;
    logic startofpacket;

    // Outputs
    logic flag_reached;

    parameter screen_percent = 80;

    logic [8:0] col;
    logic [7:0] row;

    // 320x240 image
    localparam image_width = 320;
    localparam image_length = 240;

    localparam total_pixels = image_width * image_length;

    logic [16:0] total_pixel_count;
    colour_detect #(
        .screen_percent(screen_percent)
    ) detect (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .startofpacket(startofpacket),
        .flag_reached(flag_reached)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        startofpacket = 0;
        data_in = 12'h000;
        total_pixel_count = 0;

        // Apply reset
        #20;
        reset = 0;

        // Start of packet (vSync)
        #20;
        startofpacket = 1;
        #20;
        startofpacket = 0;

        // Simulate the image frame
        for (row = 0; row < image_length; row = row + 1) begin
            for (col = 0; col < image_width; col = col + 1) begin
                if (col % 2 == 0) begin
                    data_in = 12'hF00; // Pure red (1111_0000_0000)
                end
                else if (col % 2 == 1) begin
                    data_in = 12'h000;
                end
                total_pixel_count = total_pixel_count + 1;
                #20;
            end
        end
        
        #20;
        startofpacket = 1;
        #20;
        startofpacket = 0;
        total_pixel_count = 0;

        for (row = 0; row < image_length; row = row + 1) begin
            for (col = 0; col < image_width; col = col + 1) begin
                data_in = 12'hF00; // Pure red (1111_0000_0000)
                total_pixel_count = total_pixel_count + 1;
                #20;
            end
        end

        #20;
        startofpacket = 1;
        #20;
        startofpacket = 0;
        total_pixel_count = 0;

        for (row = 0; row < image_length; row = row + 1) begin
            for (col = 0; col < image_width; col = col + 1) begin
                if (row < 192) begin
                    data_in = 12'hF00; // Pure red (1111_0000_0000)
                end
                else if (row >= 192) begin
                    data_in = 12'h000;
                end
                total_pixel_count = total_pixel_count + 1;
                #20;
            end
        end

        #10000;
        if (total_pixel_count == total_pixels) begin
            #1000;
            $finish;
        end
    end


    // Monitor the flag_reached signal
    initial begin
        $monitor("At time %t, flag_reached = %b", $time, flag_reached);
    end


endmodule
