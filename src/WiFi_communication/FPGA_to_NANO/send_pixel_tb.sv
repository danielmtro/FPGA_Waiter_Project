`timescale 1ns/1ps

module send_pixel_tb;


	localparam CLK_PERIOD = 2; // 50 MHz clock (20ns period)

	logic clk, reset;
	logic [11:0] pixel;
	logic valid_in;
	logic ready_in;
	
	logic uart_out;
	logic ready_out;
	logic valid_out;

	send_pixel DUT (
		.clk(clk),
		.rst(reset),
		.pixel(pixel),
		.valid_in(valid_in),            // Handshake protocol: valid_in (when `data_tx` is valid_in to be sent onto the UART).
		.ready_in(ready_in),
		
		.uart_out(uart_out),
		.ready_out(ready_out),      // Handshake protocol: ready_out (when this UART module is ready_out to send data).
		.valid_out(valid_out)
	);

	// Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
	 
	 assign pixel = 12'b1010_1010_1010;
	 
	 initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        reset = 0;
        valid_in = 0;
        

        // Release reset
        #(5 * CLK_PERIOD);
        reset = 1;
		
			//initiate sending of the pixel
		  valid_in = 1;
		  #(3 * CLK_PERIOD);
		  valid_in = 0;
		  
		  //wait for high byte to send
		  #(4000 * CLK_PERIOD);
        
        // wait for low byte to send
        #(4000 * CLK_PERIOD);
		  
		  //test complete
		  #(1000 * CLK_PERIOD);
        $finish();
    end
	 
endmodule