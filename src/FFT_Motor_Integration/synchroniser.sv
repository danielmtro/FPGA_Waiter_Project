module synchroniser (input clk, x, output y);
    reg x_q0, x_q1;
    always @(posedge clk)
    begin
        x_q0 <= x;    // Flip-flop #1
        x_q1 <= x_q0; // Flip-flop #2
    end
    assign y = x_q1;
endmodule