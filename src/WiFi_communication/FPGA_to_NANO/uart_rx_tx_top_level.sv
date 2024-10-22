module uart_top #(
    parameter CLKS_PER_BIT = (50000000/115200), // Baud rate 115200 with FPGA clock 50MHz
    parameter BITS_N = 8,   // Number of data bits per UART frame
    parameter PARITY_TYPE = 0  // 0 for none, 1 for odd parity, 2 for even parity
) (
    input CLOCK2_50,              // FPGA clock
    input [35:0] GPIO,          // GPIO pin for UART RX (receiving serial data)
    output [35:0] GPIO,         // GPIO pin for UART TX (transmitting serial data)
    input [BITS_N-1:0] data_tx,  // Data to be transmitted
    input [3:0] KEY,              // Button signal (e.g., from an FPGA input like KEY[1])
    
    output ready_out_tx,         // UART TX is ready to accept data
    output [BITS_N-1:0] data_rx, // Received data
    output valid_out_rx,         // Received data is valid
    output parity_error          // Parity error flag from RX
);
    logic clk;
    logic reset;
    logic gpio_rx;
    logic gpio_tx;
	
	assign clk = CLOCK2_50;
    assign reset = KEY[0];
    assign gpio_rx = GPIO[0];
    assign gpio_tx = GPIO[1];

    // UART Transmitter signals
    logic uart_tx_out;
    logic ready_out_tx_internal;
    logic valid_out_tx_internal;

    // UART Receiver signals
    logic [7:0] data_rx_internal;
    logic valid_out_rx_internal;
    logic parity_error_internal;

    // Edge detection signal
    logic button_edge;

    // Instantiate UART Transmitter
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .PARITY_TYPE(PARITY_TYPE)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .valid_in(button_edge),        // Trigger TX on button press (detected edge)
        .uart_out(uart_tx_out),
        .ready_out(ready_out_tx_internal),
        .valid_out(valid_out_tx_internal)
    );

    // Instantiate UART Receiver
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .PARITY_TYPE(PARITY_TYPE)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .uart_in(gpio_rx),               // Connect GPIO RX to the UART RX input
        .data_rx(data_rx_internal),
        .valid_out(valid_out_rx_internal),
        .ready_out(),                    // Receiver is always ready for simplicity
        .parity_error(parity_error_internal)
    );

    // Instantiate edge detection for button press
    edge_detect edge_detect1 (
        .clk(clk),
        .button(KEY[1]),                   // Button input (e.g., from FPGA input KEY[1])
        .button_edge(button_edge)       // Rising edge output
    );

    // Assign UART output and GPIO pin connections
    assign gpio_tx = uart_tx_out;          // Connect UART TX output to the GPIO TX pin
    assign data_rx = data_rx_internal;     // Received data output
    assign valid_out_rx = valid_out_rx_internal;  // Valid flag for received data
    assign parity_error = parity_error_internal;  // Parity error flag from RX
    assign ready_out_tx = ready_out_tx_internal;  // TX ready flag

endmodule
