`timescale 1 ns / 1 ns
module fft_pitch_detect_tb;

    localparam NSamples = 1024;
    localparam W        = 16;

    localparam TCLK  = 50;  // 20 MHz.
    localparam TBCLK = 300; // x6 slower

    logic clk = 0, bclk = 0;    //  Master Clock
    
    always #(TCLK/2) clk = ~clk;
    always #(TBCLK/2) bclk = ~bclk;
	 
    logic reset = 1'b1;
    
    dstream #(.N(W)) audio_input ();
    dstream #(.N($clog2(NSamples))) pitch_output ();

    fft_pitch_detect DUT (.clk(clk), .audio_clk(bclk), .reset(reset), .audio_input(audio_input), .pitch_output(pitch_output));

    logic [W-1:0] input_signal [NSamples];
    initial $readmemh("test_waveform.hex", input_signal);


    logic start = 1'b0; // Use a start flag.
    initial begin : test_procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
        reset = 1'b1;
        #(TCLK*5);
        reset = 1'b0;
        #(TCLK*5);
        start = 1'b1;
        repeat (3) @(negedge pitch_output.valid);
        #(TCLK*100);
        $finish();
    end

    // Input Driver
    integer i = 0, next_i;
    assign next_i = i < NSamples-1 ? i + 1 : 0;
    always_ff @(posedge bclk) begin : driver
        audio_input.valid <= 1'b0;
        audio_input.data <= input_signal[i];
        if (start) begin
            audio_input.valid <= 1'b1;
            if (audio_input.valid && audio_input.ready) begin
                audio_input.data <= input_signal[next_i];
                i <= next_i;
            end
        end
    end

    logic [2*W:0] output_check, expected_output;
    integer output_i = 0;
    always_ff @(posedge clk) begin : monitor
        if (pitch_output.valid) begin
            output_check <= pitch_output.data;
            output_i     <= output_i < NSamples-1 ? output_i + 1 : 0;
        end
    end


endmodule
