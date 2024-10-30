
module timer #(
    parameter MAX_MS = 2047,            // Maximum millisecond value
    parameter CLKS_PER_MS = 50000 // What is the number of clock cycles in a millisecond?
) (
    input                       clk,
    input                       reset,
    input                       up,
    input  [$clog2(MAX_MS)-1:0] start_value, // clog2 works out the min number of bits for the given number
    input                       enable,
    output [$clog2(MAX_MS)-1:0] timer_value
);

    reg [$clog2(CLKS_PER_MS):0]clock_tracker; /// define the register to hold the clock tracker
    reg [$clog2(MAX_MS)-1:0] milli_tracker;
    reg count_up;

    // increment clock tracker every clock cycle 
    always @(posedge clk)
    begin
        if(reset)
        begin
            if(up)
            begin
                milli_tracker <= 0;
                count_up <= 1;
            end
            else
            begin
                milli_tracker <= start_value;
                count_up <= 0;
            end
        end
        else if(enable)
        begin
            if(clock_tracker >= CLKS_PER_MS -1)
            begin
                clock_tracker <= 0;
                milli_tracker <= (count_up) ? milli_tracker + 1 : milli_tracker - 1;
            end
            else
            begin
                clock_tracker <= clock_tracker + 1;
            end
        end
        
    end 

    assign timer_value = milli_tracker;


endmodule
