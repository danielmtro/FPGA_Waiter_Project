 module uart_tx #(
      parameter CLKS_PER_BIT = (50000000/115200), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
      parameter BITS_N       = 8, // Number of data bits per UART frame
      parameter PARITY_TYPE  = 0  // 0 for none, 1 for odd parity, 2 for even.
) (
      input clk,
      input rst,
      input [BITS_N-1:0] data_tx,
		input valid_in,            // Handshake protocol: valid_in (when `data_tx` is valid_in to be sent onto the UART).
//      input logic ready_in,
		
		output logic uart_out,
      output logic ready_out,      // Handshake protocol: ready_out (when this UART module is ready_out to send data).
		output logic valid_out,
		output logic baud_trigger
 );

   logic [BITS_N-1:0] data_tx_temp;
   logic [2:0]        bit_n;

   enum {IDLE, START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT, HOLD_BAY} current_state, next_state;

   //setting baud Baud_rate
   integer counter = 0;
//   logic baud_trigger;

   assign baud_trigger = (counter == CLKS_PER_BIT-1);

   always_ff @(posedge clk) begin
      counter <= (counter == CLKS_PER_BIT-1) ? 0 : (current_state == IDLE) ? 0 : counter + 1;
   end
	
	logic [7:0] hold_counter;
	
	always_ff @(posedge baud_trigger) begin
		hold_counter <= (hold_counter == 8'b00000101) ? 0 : (current_state != HOLD_BAY) ? 0 : hold_counter + 1;
	end
	
	logic hold_trigger;
	assign hold_trigger = (hold_counter == 8'b00000101);
	

   always_comb begin : fsm_next_state
         case (current_state)
            IDLE:        next_state = valid_in ? START_BIT : IDLE; // Handshake protocol: Only start sending data when valid_in data comes through.
            START_BIT:   next_state = baud_trigger ? DATA_BITS : START_BIT;
            DATA_BITS:   next_state = baud_trigger ? ((bit_n == BITS_N-1) ? (PARITY_TYPE ? PARITY_BIT : STOP_BIT) : DATA_BITS) : DATA_BITS; // Send all `BITS_N` bits.
            PARITY_BIT:  next_state = (PARITY_TYPE == 0) ? STOP_BIT : (baud_trigger ? STOP_BIT : PARITY_BIT);
            STOP_BIT:    next_state = baud_trigger ? HOLD_BAY : STOP_BIT;
				HOLD_BAY:	 next_state = hold_trigger ? IDLE : HOLD_BAY;
            default:     next_state = IDLE;
         endcase
   end
   
   always_ff @( posedge clk ) begin : fsm_ff
      if (~rst) begin
         current_state <= IDLE;
         data_tx_temp <= 0;
         bit_n <= 0;
      end
      else begin
         current_state <= next_state;
         case (current_state)
            IDLE: begin // Idle -- register the data to send (in case it gets corrupted by an external module). Reset counters.
               data_tx_temp <= data_tx;
               bit_n <= 0;
            end
            DATA_BITS: begin // Data transfer -- Count up the bit-index to send.
               bit_n <= baud_trigger ? bit_n + 1'b1 : bit_n;
            end
         endcase
      end
   end

   always_comb begin : fsm_output
         uart_out = 1'b1; // Default: The UART line is high.
         ready_out = 1'b0;    // Default: This UART module is only ready_out for new data when in the IDLE state.
			valid_out = 0;
         case (current_state)
            IDLE:   begin
               ready_out = 1'b1;  // Handshake protocol: This UART module is ready_out for new data to send.
					valid_out = 0;
            end
            DATA_BITS:    begin
               uart_out = data_tx_temp[bit_n]; // Set the UART TX line to the current bit being sent.
					valid_out = 1;
            end
            START_BIT:    begin
               uart_out = 1'b0; // The start condition is a zero.
					valid_out = 1;
            end
            PARITY_BIT: begin
					valid_out = 1;
               if (PARITY_TYPE == 0) begin
						uart_out = uart_out;
               end
               else if (PARITY_TYPE == 1) begin
                  uart_out = ~^data_tx_temp;
               end
               else if (PARITY_TYPE == 2) begin
                  uart_out = ^data_tx_temp;
               end
               else begin
						uart_out = uart_out;
               end
            end
         endcase
   end

 endmodule