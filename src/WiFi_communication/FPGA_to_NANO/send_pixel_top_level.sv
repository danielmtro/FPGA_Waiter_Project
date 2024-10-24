module send_pixel_top_level #(
	parameter CLKS_PER_BIT = (50000000/115200), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
   parameter BITS_N       = 8, // Number of data bits per UART frame
   parameter PARITY_TYPE  = 0,  // 0 for none, 1 for odd parity, 2 for even.
	parameter IMAGE_SIZE	  = 4
	)(
	input CLOCK2_50,	
	//inout logic [35:0] GPIO,
	input GPIO_rx,
	output GPIO_tx,
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
	
	// UART TX
	logic uart_out;
	assign GPIO_tx = uart_out;
//	assign uart_out = GPIO[1];
	logic send_ready_out;
	logic send_valid_out;
	logic baud_trigger;

	// RX signals
	logic tx_ready_in;
	logic [7:0] data_rx;
	logic uart_in;
	logic valid_out_rx;

	assign uart_in = GPIO_rx;
	
//	initial begin: memset
//	 $readmemh("chad-ho-320x240.hex", chad_ho);
//	end
	
	send_pixel send_pixel0 (
		.clk(clk),					 // Clock signal
		.rst(reset),				 // Reset signal
		.pixel(pixel),				 // Pixel input set manually
		.valid_in(send_valid_in),    // Handshake protocol: valid_in (when `data_tx` is valid_in to be sent onto the UART).
		.ready_in(tx_ready_in),		 // Ready in received from RX code
		
		.uart_out(uart_out),		 // Transmission output connected to GPIO pin
		.ready_out(send_ready_out),  // Handshake protocol: ready_out (when this UART module is ready_out to send data).
		.valid_out(send_valid_out)	 // Valid out received by RX for tx_alert
	);

	uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .BITS_N(BITS_N),
        .PARITY_TYPE(0)
	) uart_rx (
        .clk(clk),						// clock input
        .rst(reset),						// reset
        .uart_in(uart_in),              // Connect GPIO RX to the UART RX input
        .data_rx(data_rx),				// Output data
        .valid_out(valid_out_rx),		// Valid out signal
        .ready_out(),                    // Receiver is always ready for simplicity
		.pixel_sent(tx_ready_in),		// Output signal used by ready_in for send_pixel
		.tx_alert(send_valid_out)		// Receives signal from send_pixel when data transmission is occurring
    );
	
	//debounce KEY[1]
	logic debounced_key;
	debounce #(
  		.DELAY_COUNTS(2500)/*FILL-IN*/ // 50us with clk period 20ns is ____ counts
	) debounc_key1(
		.clk(clk),
		.button(KEY[1]),
    	.button_pressed(debounced_key)
	);
	
	//import chad-ho and save into BRAM
	//--------------SEND CHAD HO---------------------------------------------	
	logic [11:0] chad_ho [IMAGE_SIZE];
	
	initial begin
		for (int i=0; i < 4; i=i+1) begin
			chad_ho[i] = (i > 1 && i <= 2000) ? 12'b1111_0000_0000 : 12'b0000_0000_1111;
		end
	end

	//count thorugh each pixel
	logic [3:0] index = 0;
//	logic [16:0] pixel_address_next;
	
	logic key_edge;
	edge_detect edge_detection(
    	.clk(clk),
    	.button(debounced_key),
    	.button_edge(key_edge)
	);
	
	//state definitions
	enum {IDLE, SEND_IMAGE} current_state, next_state;
	
	//FSM next state
	always_comb begin : FSM_next_state
		
		case (current_state)
			
			IDLE: begin
				next_state = (tx_ready_in) ? SEND_IMAGE : IDLE;
			end
			SEND_IMAGE: begin
				next_state = ((send_ready_out == 1) && (index == IMAGE_SIZE - 1)) ? IDLE : SEND_IMAGE;
			end
			default: next_state = IDLE;
			
		endcase
	end
	
	// state transition
	always_ff @(posedge clk) begin : state_transition
		if (reset == 0) begin
			current_state <= IDLE;
		end
		
		else begin
			current_state <= next_state;
		end
	end
	
	//set the counter
	always_ff @(posedge send_ready_out) begin
		
		if (reset==0) begin
			index <= 0;
		end
		
		else begin
			//count only when in SEND_IMAGE 
			case (current_state)
				IDLE: begin
					index <= 0;
				end
				SEND_IMAGE: begin
					if (index < IMAGE_SIZE) begin
						index <= index + 1;
					end
					else begin
						index <= index;
					end
				end
			endcase
		end
	end
	
	always_ff @(posedge clk) begin
		pixel <= chad_ho[index];
	end
	
//	assign pixel = chad_ho[index]; //apparently need to make this always_ff
	assign send_valid_in = (send_ready_out && (current_state == SEND_IMAGE));
	
//
//--------------------------------------------------------------------------------
//-----------SEND 10X10 TEAEM FLAG-----------------
//	logic [16:0] index;
//	logic [16:0] index_next;
//	
//	logic key_edge;
//	
//	edge_detect edge_detection(
//    .clk(clk),
//    .button(debounced_key),
//    .button_edge(key_edge)
//	);
//	
////	initialise ram image
//	logic [11:0] image [100];
//	
//	initial begin
//		for (int i=0; i < 100; i=i+1) begin
//			image[i] = (i > 25 && i < 75) ? 12'b1111_0000_1010 : 12'b0000_1111_0000;
//		end
//	end
//	
//	//state machine definition
//	enum {IDLE, SEND_IMAGE} current_state, next_state;
//	
//	//FSM nnext state logic
//	always_comb begin : FSM_next_state
//		
//		case (current_state)
//			
//			IDLE: begin
//				next_state = (key_edge) ? SEND_IMAGE : IDLE;
//			end
//			SEND_IMAGE: begin
//				next_state = ((send_ready_out == 1) && (index == 99)) ? IDLE : SEND_IMAGE;
//			end
//			default: next_state = IDLE;
//			
//		endcase
//	end
//	
//	//state transitioin
//	always_ff @(posedge clk) begin : state_transition
//		if (reset == 0) begin
//			current_state <= IDLE;
//		end
//		
//		else begin
//			current_state <= next_state;
//		end
//	end
//	
//	//logic for indexing image
//	//set the counter
//	always_ff @(posedge send_ready_out) begin
//		
//		if (reset==0) begin
//			index <= 0;
//		end
//		
//		else begin
//			//count only when in SEND_IMAGE 
//			case (current_state)
//				IDLE: begin
//					index <= 0;
//				end
//				SEND_IMAGE: begin
//					if (index < 100) begin
//						index <= index + 1;
//					end
//					else begin
//						index <= index;
//					end
//				end
//			endcase
//		end
//	end
//
//	always_ff @(posedge clk) begin
//		pixel <= image[index];
//	end
//	
//	assign send_valid_in = (send_ready_out && (current_state == SEND_IMAGE));
	
//--------------------------------------------------------------	
//-----------------SEND SINGLE PIXEL ON BUTTON PRESS-------------------
//	logic key_edge;
//	
//	edge_detect edge_detection(
//    .clk(clk),
//    .button(debounced_key),
//    .button_edge(key_edge)
//		);
//
//	assign pixel = 12'b1111_0000_1111;
//	
//	assign send_valid_in = key_edge;


//------------------------------------
//------------ON BUTTON PRESS SEND 3 DIFFERENT PIXELS CONSECUTIVELY---------------

//	logic [11:0] image [3];
//	logic [2:0] index;
//	
//	assign image[0] = 12'b1111_0000_1010; //F0A --> F0 | A
//	assign image[1] = 12'b0000_1111_0000; //0F0 --> F  | 0
//	assign image[2] = 12'b0101_1111_0001; //5F1 --> 5F | 1
//	
//	logic key_edge;
//	
//	edge_detect edge_detection(
//    .clk(clk),
//    .button(debounced_key),
//    .button_edge(key_edge)
//);
//	
//	enum {IDLE, SEND_IMAGE} current_state, next_state;
//	
//	
//	always_comb begin : FSM_next_state
//		
//		case (current_state)
//			
//			IDLE: begin
//				next_state = (key_edge) ? SEND_IMAGE : IDLE;
//			end
//			SEND_IMAGE: begin
//				next_state = ((send_ready_out == 1) && (index == 3'b010)) ? IDLE : SEND_IMAGE;
//			end
//			default: next_state = IDLE;
//			
//		endcase
//	end
//	
//
//	//state transition
//	always_ff @(posedge clk) begin : state_transition
//		if (reset == 0) begin
//			current_state <= IDLE;
//		end
//		
//		else begin
//			current_state <= next_state;
//		end
//	end
//	
//	//set the counter
//	always_ff @(posedge send_ready_out) begin
//		
//		if (reset==0) begin
//			index <= 0;
//		end
//		
//		else begin
//			//count only when in SEND_IMAGE 
//			case (current_state)
//				IDLE: begin
//					index <= 0;
//				end
//				SEND_IMAGE: begin
//					if (index < 3) begin
//						index <= index + 1;
//					end
//					else begin
//						index <= index;
//					end
//				end
//			endcase
//		end
//	end
//	
////	always_comb begin : FSM_state_output
////	
////		case (current_state)
////			IDLE: begin
////			
////			end
////			
////			SEND_IMAGE: begin
////			
////			end
////	
////	end
////	always_comb begin
////	always_ff @(posedge clk) begin
////		if (reset == 0) begin
////			index <= 0;
////		end
////		else if (index < 3) begin
////			if (send_ready_out == 1) begin
////				index <= index + 1;
////			end
////			else begin
////				index <= index + 0;
////			end
////		end
////		else begin
////			if (key_edge == 1) begin
////				index <= 0;
////			end
////			else begin
////				index <= index + 0;
////			end
////		end
////	end
//	
////	always_ff @(posedge clk) begin
//////	always_comb begin
//////		if (!reset) begin
//////			index <= 0;
//////		end
//////		else begin
//////			index <= index;
//////		end
////		pixel <= image[index];
////	end
//	
//	assign pixel = image[index];
//	assign send_valid_in = (send_ready_out && (current_state == SEND_IMAGE));
	
//--------------------------------------
endmodule

