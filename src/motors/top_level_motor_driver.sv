module top_level_motor_driver #(
    parameter CLKS_PER_BIT = 50_000_000/115_200,
    parameter BITS_N = 8,
    parameter NUM_BYTES = 25
) (
    input wire clk_50,
    output [17:0] LEDR,
    input wire [17:0]SW, 
    output wire UART_OUT // GPIO5
);

wire ready;

json_command_sender #(
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .BITS_N(BITS_N),
    .NUM_BYTES(NUM_BYTES)
) json (
    .clk(clk_50),
    .rst(SW[17]),
    .valid(SW[1]),
    .uart_out(UART_OUT),
    .ready(ready)
);

assign LEDR[17] = SW[17];
assign LEDR[0] = UART_OUT;
assign LEDR[2] = ready;

endmodule