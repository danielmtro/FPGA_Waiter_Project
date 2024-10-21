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
	assign clk = CLOCK2_50;

	logic [7:0] data_tx;
	assign data_tx = 8'b1111_0000; // XF0
	
	logic reset;
	assign reset = KEY[0];
	
	logic valid_in;
	
	logic uart_ready_out;
	logic uart_valid_out;
	
	logic button_edge;
	
	edge_detect edge_detect1(
    .clk(clk),
    .button(KEY[1]),
    .button_edge(button_edge)
   );
	
	assign valid_in = button_edge;
	
	logic baud_trigger;
	assign LEDG[0] = baud_trigger;
	uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .PARITY_TYPE(0) // Even parity
    ) uart_tx (
        .clk(clk),
        .rst(reset),
        .data_tx(data_tx),
        .valid_in(valid_in),
        .uart_out(GPIO[1]),
        .ready_out(uart_ready_out),
		  .baud_trigger(baud_trigger)
    ); 
	 
endmodule 