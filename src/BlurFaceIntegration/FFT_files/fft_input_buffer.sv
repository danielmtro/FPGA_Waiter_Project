module fft_input_buffer #(
    parameter W = 16,
    parameter NSamples = 1024
) (
    input                clk,
     input                reset,
     input                audio_clk,
    dstream.in           audio_input,
     output logic [W-1:0] fft_input,
     output logic         fft_input_valid
);
    logic fft_read = 0;
    logic [$clog2(NSamples):0] n = 0;

    logic full, wr_full;
    async_fifo u_fifo (.aclr(reset),
                        .data(audio_input.data),
                        .wrclk(audio_clk),
                        .wrreq(audio_input.valid),
                        .wrfull(wr_full),
                        .q(fft_input),          
                        .rdclk(clk),      
                        .rdreq(fft_read),         
                        .rdfull(full));
    assign audio_input.ready = !wr_full;

    assign fft_input_valid = fft_read; // The Async FIFO is set such that valid data is read out whenever the rdreq flag is high.
    
    //TODO implement a counter n to set fft_read to 1 when the FIFO becomes full (use full, not wr_full).
    // Then, keep fft_read set to 1 until 1024 (NSamples) samples in total have been read out from the FIFO.

    logic start_count;

    always_ff @(posedge clk) begin

        if(full || start_count) begin
            n <= n + 1;
        end
        else begin
            n <= 0;
        end
    end

    always_comb begin

        //  check to see that the counting has begun
        if(n > 0 && n < NSamples) begin
            start_count = 1;
        end
        else begin
            start_count = 0;
        end

        if(full || start_count) begin
            fft_read = 1;
        end
        else begin
            fft_read = 0;
        end
    end

endmodule