module fft_find_peak #(
    parameter NSamples = 1024, // 1024 N-points
    parameter W        = 33,   // For 16x2 + 1
	parameter NBits    = $clog2(NSamples)

) (
    input                        clk,
    input                        reset,
    input  [W-1:0]               mag,
    input                        mag_valid,
    output logic [W-1:0]         peak = 0,
    output logic [NBits-1:0]     peak_k = 0,
    output logic                 peak_valid
);
    logic [NBits-1:0] i = 0, k;
	always_comb for (integer j=0; j<NBits; j=j+1) k[j] = i[NBits-1-j]; // bit-reversed index
    // determine if the peak is valid;

    logic [W-1:0]         peak_temp   = 0;
    logic [NBits-1:0]     peak_k_temp = 0;

    always_ff @(posedge clk) begin : find_peak
        //TODO Find the peak (maximum) value out of a window of 1024 streamed samples, streamed in one at a time.
        // Store the corresponding k-index representing that value in peak_k. Set peak_valid to 1 for 1 clock cycle once all 1024 values have been streamed through.
        // Use the counter i to count from 0 to 1023. Reset all registers after the 1024th value of i, in preparation for the next FFT window.
        // The FFT k-index is represented by bit-reversing i.

        // check if we are resetting. Then reset all of the values
        if(reset) begin
            peak_k_temp <= 0;
            peak_temp <= 0;
            peak_valid <=0;
            i <= 0;
        end
        // if we've reached theend of the packet then set peak_valid correctly
        else if(i == NSamples - 1) begin

            // set the output variables
            peak_k <= peak_k_temp;
            peak <= peak_temp;

            // set valid to 1 and reset the maximum peak detected
            peak_valid <= 1;
            peak_temp <= 0;
            peak_k_temp <= 0;
            i <= 0;

        end
        // check if the magnitue provided is valid
        else if(mag_valid) begin
            
            // increment the index if the mag is bigger than the peak
            if(mag > peak_temp) begin
                if(k[NBits - 1] != 1'b1) begin
                    peak_temp <= mag;
                    peak_k_temp <= k;
                end
            end

            i <= i + 1;
            peak_valid <= 0;
        end
        else begin

            // reset registers in mag not valid
            peak_k_temp <= 0;
            peak_temp <= 0;
            peak_valid <=0;
            i <= 0;
        end
    end
endmodule
