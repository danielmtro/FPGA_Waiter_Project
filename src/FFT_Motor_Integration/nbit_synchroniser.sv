module nbit_synchroniser #(
	parameter N = 2)(
	input clk,
    input x_valid,
	input [N - 1:0]x,
	output [N - 1:0] y);

    reg [N - 1:0] x_q0, x_q1;
    always @(posedge clk)
    begin
        if(x_valid) begin
            x_q0 <= x;    // Flip-flop #1
        end
        x_q1 <= x_q0; // Flip-flop #2
    end
    assign y = x_q1;
endmodule