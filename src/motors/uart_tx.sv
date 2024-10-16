 module uart_tx #(
      parameter CLKS_PER_BIT = (50_000_000/115_200), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
      parameter BITS_N       = 8, // Number of data bits per UART frame
      parameter PARITY_TYPE  = 0  // 0 for none, 1 for odd parity, 2 for even.
) (
      input clk,
      input rst,
      input [BITS_N-1:0] data_tx,
      output logic uart_out,
      input valid,            // Handshake protocol: valid (when `data_tx` is valid to be sent onto the UART).
      output logic ready      // Handshake protocol: ready (when this UART module is ready to send data).
 );

   logic [$clog2(CLKS_PER_BIT) - 1:0] count;
   logic [$clog2(CLKS_PER_BIT) - 1:0] pcount;
   logic [$clog2(CLKS_PER_BIT) - 1:0] startcount;
   logic [$clog2(CLKS_PER_BIT) - 1:0] stopcount;

   logic [BITS_N-1:0] data_tx_temp;
   logic [2:0]        bit_n;
   logic              even;

   // Section to determine if there is an even number of 1's in the overall number
   logic [$clog2(BITS_N) -1: 0] parity_count;
   integer i;
   always_comb begin 
      parity_count = 0;
      for (i = 0; i < BITS_N; i = i + 1) begin
         parity_count = parity_count + data_tx_temp[i];
      end
      even = (parity_count % 2 == 0);
   end


   // section to keep track of the count of data bits clk cycles 
   always_ff @(posedge clk) begin

      // if we've reached our desired value
      if(current_state != DATA_BITS) begin 
         count <= 0;    // reset the counter in no data bit sate
      end
      else if(count == CLKS_PER_BIT)begin
         count <= 0;    // reset the counter if we reach the target clks per bit
      end
      else begin
         count <= count + 1;  // increment 
      end
   end


   // section to keep track of the count of parity bit
   always_ff @(posedge clk) begin

      // if we've reached our desired value
      if(current_state != PARITY_BIT) begin 
         pcount <= 0;    // reset the counter in no data bit sate
      end
      else if(pcount == CLKS_PER_BIT)begin
         pcount <= 0;    // reset the counter if we reach the target clks per bit
      end
      else begin
         pcount <= pcount + 1;  // increment 
      end
   end

   // section to keep track of the count of start bit
   always_ff @(posedge clk) begin

      // if we've reached our desired value
      if(current_state != START_BIT) begin 
         startcount <= 0;    // reset the counter in no data bit sate
      end
      else if(startcount == CLKS_PER_BIT)begin
         startcount <= 0;    // reset the counter if we reach the target clks per bit
      end
      else begin
         startcount <= startcount + 1;  // increment 
      end
   end

   // section to keep track of the count of stop bit
   always_ff @(posedge clk) begin

      // if we've reached our desired value
      if(current_state != STOP_BIT) begin 
         stopcount <= 0;    // reset the counter in no data bit sate
      end
      else if(startcount == CLKS_PER_BIT)begin
         stopcount <= 0;    // reset the counter if we reach the target clks per bit
      end
      else begin
         stopcount <= stopcount + 1;  // increment 
      end
   end


   enum {IDLE, START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT} current_state, next_state;

   always_comb begin : fsm_next_state
         case (current_state)
            IDLE:        next_state = valid ? START_BIT : IDLE; // Handshake protocol: Only start sending data when valid data comes through.
            START_BIT:   next_state = (startcount == CLKS_PER_BIT - 1) ? DATA_BITS : START_BIT;
            DATA_BITS:   begin 
               if( (bit_n != BITS_N - 1) || (count != CLKS_PER_BIT - 1)) begin
                  next_state = DATA_BITS;      // If we haven't reached the end of the data stay in data bits
               end
               else if(PARITY_TYPE != 0) begin
                  next_state = PARITY_BIT;      // if we want a parity bit move to parity state
               end
               else begin 
                  next_state = STOP_BIT;        // otherwise move to stop state
               end
            end 
            PARITY_BIT:  next_state = (pcount == CLKS_PER_BIT - 1) ? STOP_BIT : PARITY_BIT;   // send to stop_bit afterwards
            STOP_BIT:    next_state = (stopcount == CLKS_PER_BIT - 1) ? IDLE : STOP_BIT;
            default:     next_state = IDLE;
         endcase
   end
   
   always_ff @( posedge clk ) begin : fsm_ff
      if (rst) begin
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

               // check if we've reached the correct time
               if(count == CLKS_PER_BIT - 1) begin
                  bit_n <= bit_n + 1'b1;
               end
               else begin
                  bit_n <= bit_n;
               end

            end
         endcase
      end
   end

   always_comb begin : fsm_output
         uart_out = 1'b1; // Default: The UART line is high.
         ready = 1'b0;    // Default: This UART module is only ready for new data when in the IDLE state.
         case (current_state)
            IDLE:   begin
               ready = 1'b1;  // Handshake protocol: This UART module is ready for new data to send.
            end
            DATA_BITS:    begin
               uart_out = data_tx_temp[bit_n]; // Set the UART TX line to the current bit being sent.
            end
            PARITY_BIT: begin 
               if(PARITY_TYPE == 1)begin
                  uart_out = even;             // If we're detecting even numbers set it to even signal
               end
               else if(PARITY_TYPE == 2) begin 
                  uart_out = ~even;            // If we're detecting odd numbers set it to inverse of even
               end
               else begin
                  uart_out = 1'b0;
               end
            end
            START_BIT:    begin
               uart_out = 1'b0; // The start condition is a zero.
            end
         endcase
   end

 endmodule