// File digital_cam_impl1/frame_buffer.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// create a buffer to store pixels data for a frame of 320x240 pixels;
// data for each pixel is 12 bits;
// that is 76800 pixels; hence, address is represented on 17 bits 
// (2^17 = 131072 > 76800);
// Notes: 
// 1) If we wanted to work with 640x480 pixels, that would require
// an amount of embedded RAM that is not available on the Cyclone IV E of DE2-115;
// 2) We create the buffer with 76800 by stacking-up two blocks
// of 2^16 = 65536 addresses; 
// no timescale needed

module frame_buffer(
input wire [11:0] data,
input wire [16:0] rdaddress,
input wire rdclock,
input wire [16:0] wraddress,
input wire wrclock,
input wire wren,
output reg [11:0] q
);




// read signals
wire [11:0] q_top;
wire [11:0] q_bottom;
// write signals
reg wren_top;
reg wren_bottom;

  my_frame_buffer_15to0 Inst_buffer_top(
      .data(data[11:0]),
    .rdaddress(rdaddress[15:0]),
    .rdclock(rdclock),
    .wraddress(wraddress[15:0]),
    .wrclock(wrclock),
    .wren(wren_top),
    .q(q_top));

  my_frame_buffer_15to0 Inst_buffer_bottom(
      .data(data[11:0]),
    .rdaddress(rdaddress[15:0]),
    .rdclock(rdclock),
    .wraddress(wraddress[15:0]),
    .wrclock(wrclock),
    .wren(wren_bottom),
    .q(q_bottom));

  always @(wraddress[16], wren) begin
    case(wraddress[16])
    1'b0 : begin
      wren_top <= wren;
      wren_bottom <= 1'b0;
    end
    1'b1 : begin
      wren_top <= 1'b0;
      wren_bottom <= wren;
    end
    default : begin
      wren_top <= 1'b0;
      wren_bottom <= 1'b0;
    end
    endcase
  end

  always @(rdaddress[16], q_top, q_bottom) begin
    case(rdaddress[16])
    1'b0 : begin
      q <= q_top;
    end
    1'b1 : begin
      q <= q_bottom;
    end
    default : begin
      q <= 12'b000000000000;
    end
    endcase
  end


endmodule
