// File digital_cam_impl1/RGB.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
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

// no timescale needed

module RGB(
input wire [11:0] Din,
input wire Nblank,
output wire [7:0] R,
output wire [7:0] G,
output wire [7:0] B
);

// niveau de gris du pixels sur 8 bits
// signal indique les zone d'affichage, hors la zone d'affichage
// les trois couleurs prendre 0
// les trois couleurs sur 10 bits




  assign R = Nblank == 1'b1 ? {Din[11:8],Din[11:8]} : 8'b00000000;
  assign G = Nblank == 1'b1 ? {Din[7:4],Din[7:4]} : 8'b00000000;
  assign B = Nblank == 1'b1 ? {Din[3:0],Din[3:0]} : 8'b00000000;

endmodule
