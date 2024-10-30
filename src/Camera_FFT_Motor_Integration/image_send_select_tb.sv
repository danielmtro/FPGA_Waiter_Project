`timescale 1ns / 1ps

module image_send_fsm_tb;
    
    localparam WAIT_TIME = 10_000_000;
    localparam RESET_TIME = 1_000_000;
    localparam [3:0] TABLE_STATE = 4'b0000;

    logic clk;
    logic [11:0] norm_in;
    logic [11:0] blur;
    logic [3:0] state;
    logic image_ready;

    wire reset_signal;
    wire [11:0] data_out;

    image_send_select #(
        .WAIT_TIME(WAIT_TIME),
        .RESET_TIME(RESET_TIME),
        .TABLE_STATE(TABLE_STATE)
        ) i_s_fsm (
        .clk(clk),
        .norm_in(norm_in),
        .blur_in(blur),
        .state(state),
        .image_ready(image_ready),
        .reset_signal(reset_signal),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        norm_in = 12'b0;
        blur = 12'b0;
    end

    always #10 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();

        norm_in = 12'b1111_0000_1111;
        blur = 12'b0000_1111_0000;
        state = 4'b0000;
        image_ready = 0;
        
        wait(~reset_signal);
        image_ready = 1'b1;

        #20;

        image_ready = 1'b0;

        #20;

        wait(~reset_signal);
        image_ready = 1'b1;

        #20;

        image_ready = 1'b0;

        #20;

        wait(~reset_signal);
        image_ready = 1'b1;

        #20;

        image_ready = 1'b0;

        #20;

        $finish();

    end

endmodule