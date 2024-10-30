module address_generator(
    input clk_25_vga,
    input logic vga_ready,
    input logic resend,
    output logic vga_start_out,
    output logic vga_end_out,
    output logic [16:0] rdaddress
);

// create counter with back pressure
  integer row = 0, col = 0;
  integer row_old = 0, col_old = 0;
  reg vga_start, vga_end;
  logic [16:0] address;

  always_ff @(posedge clk_25_vga) begin
    
    if(resend)
      begin
        col = 0; row= 0;
      end
    else if(vga_ready) begin
      if(col >= 319) begin
        col<= 0;
        if(row >= 239) row <= 0;
        else row <= row + 1;
      end
      else col <= col + 1;

      row_old <= row;
      col_old <= col;
    end
	
  end
  
  // Set VGA start and end
  always @(*) begin

    // set start of packet
		if(col_old == 0 && row_old == 0) begin
			vga_start = 1;
		end
		else vga_start = 0;
		
    // set end of packet
		if(col_old == 319 && row_old == 239) vga_end = 1;
		else vga_end = 0;

    // use the current row and column because there will be a 1 cycle delay
    address = row * 320 + col;
  end

  assign vga_start_out = vga_start;
  assign vga_end_out = vga_end;
  assign rdaddress = address;

endmodule