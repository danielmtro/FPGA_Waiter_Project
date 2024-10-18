module send_pixel_top_level #(
	parameter CLKS_PER_BIT = (50000000/115200), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
   parameter BITS_N       = 8, // Number of data bits per UART frame
   parameter PARITY_TYPE  = 0,  // 0 for none, 1 for odd parity, 2 for even.
	parameter IMAGE_SIZE	  = 100
	)(

	input CLOCK2_50,
	
	output logic [35:0] GPIO,
	input logic [3:0] KEY

);

//   (* ram_init_file = "chad-ho-320x240.mif" *)  logic [11:0]  chad_ho [76800];

	logic clk;
	assign clk = CLOCK2_50;
	
	logic reset;
	assign reset = KEY[0];
	
	logic [11:0] pixel;
	logic send_valid_in;
	logic send_ready_in;
	
	logic uart_out;
	assign GPIO[1] = uart_out;
//	assign uart_out = GPIO[1];
	logic send_ready_out;
	logic send_valid_out;
	
	
   
	
//	initial begin: memset
//	 $readmemh("chad-ho-320x240.hex", chad_ho);
//	end
	
	send_pixel send_pixel0 (
		.clk(clk),
		.rst(reset),
		.pixel(pixel),
		.valid_in(send_valid_in),            // Handshake protocol: valid_in (when `data_tx` is valid_in to be sent onto the UART).
		.ready_in(send_ready_in),
		
		.uart_out(uart_out),
		.ready_out(send_ready_out),      // Handshake protocol: ready_out (when this UART module is ready_out to send data).
		.valid_out(send_valid_out)
	);
	//import chad-ho and save into BRAM
	
	//-----------------------------------------------------------
	//count thorugh each pixel
//	logic [16:0] pixel_address = 0;
//	logic [16:0] pixel_address_next;
//	
//	always_comb begin
//			pixel_address_next <= (send_ready_out) ? ((pixel_address == IMAGE_SIZE - 1) ? 0 : pixel_address + 1) : pixel_address;	
//			
//	end
//	
//	always_ff @(posedge clk) begin
//		if (!reset) begin
//			pixel_address <= 0;
//		end
//		else begin
//			pixel_address <= pixel_address_next;
//			pixel <= chad_ho[pixel_address];
//		end
//	end
//pulse send_valid_in on the changover of pixel addresses
//	assign send_valid_in = (pixel_address_next != pixel_address);
//
//--------------------------------------------------------------------------------

	logic [16:0] index;
	logic [16:0] index_next;
	
	always_comb begin
		index_next <= (send_ready_out) ? ((index == IMAGE_SIZE - 1) ? 0 : index + 1) : index;
	end
	
	always_ff @(posedge clk) begin
		if (!reset) begin
			index <= 0;
			pixel <= 12'b1111_0000_0000;
		end
		else begin
			index <= index_next;
			pixel <= ((index < 25) || (index > 75)) ? 12'b1111_0000_0000 : 12'b0000_0000_1111;
		end
	end
	
	assign send_valid_in = (index != index_next);
	
//--------------------------------------------------------------	
//	assign pixel = chad_ho[pixel_address];
	
endmodule

