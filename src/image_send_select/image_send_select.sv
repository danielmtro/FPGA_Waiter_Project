`timescale 1ns / 1ps

module image_send_select # (
    parameter WAIT_TIME = 50_000_000, // 1 second
    parameter RESET_TIME = 50_000_000, // 1 second
    parameter [3:0] TABLE_STATE = 4'b0100
    ) (
    input logic clk,  // 50MHz

    input logic [11:0] norm_in,   // Normal image
    input logic [11:0] blur_in,   // Blurred face image
    
    input logic [3:0] state,      // Check for table state
    input logic image_ready,      // When frame has been recieved onto the arduino

    output logic reset_signal,    // Reset for Arduino image sender
    output logic [11:0] data_out  // Output of pixel
);

logic [25:0] wait_counter;
logic [25:0] reset_counter;

enum {IDLE, RAW_IMAGE, WAIT, BLUR_FACE} current_state, next_state;

always_comb begin : fsm_next_state
    case (current_state)
        IDLE:       next_state = (state == TABLE_STATE) ? RAW_IMAGE : IDLE;
        RAW_IMAGE:  next_state = image_ready ? WAIT : RAW_IMAGE;
        WAIT:       next_state = (wait_counter == WAIT_TIME) ? BLUR_FACE : WAIT;
        BLUR_FACE:  next_state = image_ready ? IDLE : BLUR_FACE;
        default:    next_state = IDLE;
    endcase
end

always_ff @(posedge clk) begin : counter_for_wait
    current_state <= next_state;
    if (current_state == WAIT) begin
        wait_counter <= wait_counter + 1;
    end
    else begin
        wait_counter <= 0;
    end
end

always_ff @(posedge clk) begin : counter_for_reset_signal
    if ((current_state == RAW_IMAGE || current_state == BLUR_FACE) && reset_signal) begin // Starts count when in raw or blur, and when reset_signal is high
        reset_counter <= reset_counter + 1;
        if (reset_counter == RESET_TIME) begin
            reset_counter <= 0;
        end
    end
    else begin
        reset_counter <= 0;
    end

end

always_comb begin : pixel_output
    case (current_state)
        IDLE        : begin
            data_out = 12'b0;
            reset_signal = 1'b1;
        end
        
        RAW_IMAGE   : begin
            data_out = norm_in;
            reset_signal = (reset_counter == RESET_TIME) ? 1'b0 : 1'b1;
        end

        WAIT        : begin
            data_out = 12'b0;
            reset_signal = 1'b1;
        end

        BLUR_FACE   : begin
            data_out = blur_in;
            reset_signal = (reset_counter == RESET_TIME) ? 1'b0 : 1'b1;
        end
    endcase
end

endmodule
