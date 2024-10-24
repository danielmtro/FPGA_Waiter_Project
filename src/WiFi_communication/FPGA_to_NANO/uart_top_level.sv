module uart_top_level #(
	parameter CLKS_PER_BIT = (50000000/115200), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
   parameter BITS_N       = 8, // Number of data bits per UART frame
   parameter PARITY_TYPE  = 0  // 0 for none, 1 for odd parity, 2 for even.
	)(

	input CLOCK2_50,
	
	output logic [35:0] GPIO,
	input logic [3:0] KEY,
	output [7:0] LEDG

);
	logic clk;
	logic reset;

	// UART TX signals
	logic [7:0] data_tx;
	logic valid_in;
	logic uart_ready_out;
	logic uart_valid_out;
	logic uart_out;

	logic button_edge;

	logic baud_trigger;
	
	logic [7:0] data_rx;
	logic tx_ready_in;
	logic uart_in;

	// UART RX signals

	assign clk = CLOCK2_50;
	assign reset = KEY[0];
	assign LEDG[0] = baud_trigger;
	assign data_tx = 8'b1111_0000; // XF0

	// Detect edge from button press
	edge_detect edge_detect1(
    .clk(clk),
    .button(KEY[1]),
    .button_edge(button_edge)
   );
	
	assign valid_in = button_edge;
	
	uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .PARITY_TYPE(0) // Even parity
    ) uart_tx (
        .clk(clk),
        .rst(reset),
        .data_tx(data_tx),
        .valid_in(valid_in),
        .uart_out(uart_out),
        .ready_out(uart_ready_out),
		.ready_in(tx_ready_in),
		.baud_trigger(baud_trigger),
		.valid_out(uart_valid_out)
    ); 

	uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .PARITY_TYPE(0)
    ) uart_rx (
        .clk(clk),
        .rst(reset),
        .uart_in(uart_in),               // Connect GPIO RX to the UART RX input
        .data_rx(data_rx),
        .valid_out(valid_out_rx),
        .ready_out(),                    // Receiver is always ready for simplicity
		.baud_trigger(baud_trigger),
		.pixel_sent(tx_ready_in),
		.tx_alert(uart_valid_out)
    );
	 
endmodule 