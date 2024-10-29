`timescale 1ns / 1ps

module image_send_fsm (
    input logic clk,

    input logic [11:0] data_in,
    input logic sop,
    input logic eop,
    input logic ready,
    input logic valid,

    input logic at_table,
    input logic frame_recieved,

    output logic [11:0] data_out
);

logic [11:0] blur_face;

enum {IDLE, RAW_IMAGE, BLUR_FACE} current_state, next_state;

state_type current_state = IDLE, next_state;

always_comb begin : fsm_next_state
    case (current_state)
        IDLE:       next_state = at_table ? RAW_IMAGE : IDLE;
        RAW_IMAGE:  next_state = frame_recieved ? BLUR_FACE : RAW_IMAGE;
        BLUR_FACE:  next_state = frame_recieved ? IDLE : BLUR_FACE
        default:    next_state = IDLE;
    endcase
end

always_ff @(posedge clk) begin
    current_state <= next_state;
end


always_comb begin : pixel_output
    case (current_state)
        IDLE        : begin
            data_out = 12'b0;
        end
        
        RAW_IMAGE   : begin
            data_out = data_in;
        end

        BLUR_FACE   : begin
            data_out = blur_face;
        end
    endcase
end

blurring_filter blur_face(
    .clk(clk),
    .ready(ready),
    .valid(valid),
    .startofpacket_in(sop),
    .endofpacket_in(eop),
    .data_in(data_in),
    .data_out(blur_face)
);

endmodule
