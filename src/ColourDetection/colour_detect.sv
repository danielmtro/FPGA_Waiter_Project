/*

Module takes in a pixel stream. Keeps listening to the pixel stream
for 320 x 240 and then outputs a signal if the amount of red was above
a threshold.

*/


module colour_detect #(
    parameter THRESHOLD = 1152000 // about 50% of the colour in the image
)(

    input clk,
    input [11:0]pixel,
    input sop,  // lets us know when a frame starts and end
    input eop,
    output colour_flag

);

    logic [3:0] red, green, blue;
    logic cflag = 0;

    assign red = pixel[11:8];
    assign green = pixel[7:4];
    assign blue = pixel[3:0];

    // determine how the count should increment
    integer count = 0;
    always_ff @(posedge clk) begin
        if(sop) begin
            count <= 0;
        end
        else begin
            count <= count + red;
        end
    end

    // determine what the colour flag should be set as
    always_ff @(posedge clk) begin
        if(eop) begin
            cflag = (count > THRESHOLD) ? 1'b1 :1'b0;
        end
    end
    
    assign colour_flag = cflag;

endmodule