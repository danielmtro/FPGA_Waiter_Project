module static_data_initialisation #(
	parameter NumPixels = 320*240,
    parameter DATA_WIDTH = 12
)(
    input  logic        clk,             
    input  logic        reset,
	input  logic        ready, 
    
    output logic [DATA_WIDTH - 1:0] data,    // 12 bit data output
    output logic        startofpacket,   // Start of packet signal
    output logic        endofpacket,     // End of packet signal
    output logic        valid            // valid output
    
);

    // Image ROMs:
	 // The ram_init_file is a Quartus-only directive
	//specifying the name of the initialisation file,
	//and Verilator will ignore it.

    (* ram_init_file = "chad-ho-320x240.mif" *)  logic [DATA_WIDTH-1:0]  linear_grad [NumPixels];

    // The pixel counter/index. Set pixel_index_next in an always_comb block.
    // Set pixel_index <= pixel_index_next in an always_ff block.
    logic [18:0] pixel_index = 0, pixel_index_next; 
 
    // Registers for reading from each ROM.
    logic [DATA_WIDTH-1:0] linear_grad_q; 
      
    logic read_enable; // Need to have a read enable signal for the BRAM

    // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.
    assign read_enable = reset | (valid & ready); 

    always_ff @(posedge clk) begin : bram_read // This block is for correctly inferring BRAM in Quartus - we need read registers!
        if (read_enable) begin
            linear_grad_q   <= linear_grad[pixel_index_next];
        end
    end

    logic [DATA_WIDTH-1:0] current_pixel; 

    // set the current_pixel based on the reg value;
    always_comb begin
        current_pixel <= linear_grad_q;
    end

    assign valid = (reset) ? 0 : 1;                    // Data valid (constant)
    assign startofpacket = (pixel_index == 0);         // Start of frame
    assign endofpacket = (pixel_index == NumPixels-1); // End of frame

    // set the data as the current pixel for output streaming
    assign data = current_pixel;

    assign pixel_index_next = (reset || pixel_index == NumPixels - 1) ? 0 : pixel_index + 1;
    
    // flip flop to update the pixel_index value
    always_ff @(posedge clk) begin
        if (reset) begin
            pixel_index <= 0;
        end else if (valid && ready) begin
            pixel_index <= pixel_index_next;
        end
    end

endmodule