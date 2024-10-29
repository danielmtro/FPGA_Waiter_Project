// File digital_cam_impl1/ov7670_registers.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
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

// register settings for the OV7670 camera (partially from OV7670.c
// in the Linux Kernel)
//
// this is tricky; based on my experience, using an OV7670 camera module
// has a LOT to do with how we set/program the camera's registers;
// it seems that the register values here get it right; thanks to the guys
// who managed to dig this up (consequence of the rather poor datasheet
// from OmniVision): Mike Field, Christopher Wilson;
// 
// Notes:
// 1) Regarding the WITH SELECT Statement:
//      WITH sreg(sel) SELECT
//           finished <= '1' when x"FFFF",
//                       '0' when others;
// This means the transfer is finished the first time sreg ends up as "FFFF",  
// i.e. Need Sequential Addresses in the below case statements 
// no timescale needed

module ov7670_registers(
input wire clk,
input wire resend,
input wire advance,
output wire [15:0] command,
output reg finished
);




reg [15:0] sreg;
reg [7:0] address = 1'b0;

  assign command = sreg;
  always @(*) begin
    case(sreg)
      16'hFFFF : finished <= 1'b1;
      default : finished <= 1'b0;
    endcase
  end

  always @(posedge clk) begin
    if(resend == 1'b1) begin
      address <= {8{1'b0}};
    end
    else if(advance == 1'b1) begin
      address <= (address) + 1;
    end
    case(address)
    8'h00 : begin
      sreg <= 16'h1280;
      // COM7   Reset
    end
    8'h01 : begin
      sreg <= 16'h1280;
      // COM7   Reset
    end
    8'h02 : begin
      sreg <= 16'h1204;
      // COM7   Size & RGB output
    end
    8'h03 : begin
      sreg <= 16'h1100;
      // CLKRC  Prescaler - Fin/(1+1)
    end
    8'h04 : begin
      sreg <= 16'h0C00;
      // COM3   Lots of stuff, enable scaling, all others off
    end
    8'h05 : begin
      sreg <= 16'h3E00;
      // COM14  PCLK scaling off
    end
    8'h06 : begin
      sreg <= 16'h8C00;
      // RGB444 Set RGB format
    end
    8'h07 : begin
      sreg <= 16'h0400;
      // COM1   no CCIR601
    end
    8'h08 : begin
      sreg <= 16'h4010;
      // COM15  Full 0-255 output, RGB 565
    end
    8'h09 : begin
      sreg <= 16'h3a04;
      // TSLB   Set UV ordering,  do not auto-reset window
    end
    8'h0A : begin
      sreg <= 16'h1438;
      // COM9  - AGC Celling
    end
    8'h0B : begin
      sreg <= 16'h4f40;
      //x"4fb3"; -- MTX1  - colour conversion matrix
    end
    8'h0C : begin
      sreg <= 16'h5034;
      //x"50b3"; -- MTX2  - colour conversion matrix
    end
    8'h0D : begin
      sreg <= 16'h510C;
      //x"5100"; -- MTX3  - colour conversion matrix
    end
    8'h0E : begin
      sreg <= 16'h5217;
      //x"523d"; -- MTX4  - colour conversion matrix
    end
    8'h0F : begin
      sreg <= 16'h5329;
      //x"53a7"; -- MTX5  - colour conversion matrix
    end
    8'h10 : begin
      sreg <= 16'h5440;
      //x"54e4"; -- MTX6  - colour conversion matrix
    end
    8'h11 : begin
      sreg <= 16'h581e;
      //x"589e"; -- MTXS  - Matrix sign and auto contrast
    end
    8'h12 : begin
      sreg <= 16'h3dc0;
      // COM13 - Turn on GAMMA and UV Auto adjust
    end
    8'h13 : begin
      sreg <= 16'h1100;
      // CLKRC  Prescaler - Fin/(1+1)
    end
    8'h14 : begin
      sreg <= 16'h1711;
      // HSTART HREF start (high 8 bits)
    end
    8'h15 : begin
      sreg <= 16'h1861;
      // HSTOP  HREF stop (high 8 bits)
    end
    8'h16 : begin
      sreg <= 16'h32A4;
      // HREF   Edge offset and low 3 bits of HSTART and HSTOP
    end
    8'h17 : begin
      sreg <= 16'h1903;
      // VSTART VSYNC start (high 8 bits)
    end
    8'h18 : begin
      sreg <= 16'h1A7b;
      // VSTOP  VSYNC stop (high 8 bits) 
    end
    8'h19 : begin
      sreg <= 16'h030a;
      // VREF   VSYNC low two bits
    end
    8'h1A : begin
      sreg <= 16'h0e61;
      // COM5(0x0E) 0x61
    end
    8'h1B : begin
      sreg <= 16'h0f4b;
      // COM6(0x0F) 0x4B 
    end
    8'h1C : begin
      sreg <= 16'h1602;
      //
    end
    8'h1D : begin
      sreg <= 16'h1e37;
      // MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
    end
    8'h1E : begin
      sreg <= 16'h2102;
    end
    8'h1F : begin
      sreg <= 16'h2291;
    end
    8'h20 : begin
      sreg <= 16'h2907;
    end
    8'h21 : begin
      sreg <= 16'h330b;
    end
    8'h22 : begin
      sreg <= 16'h350b;
    end
    8'h23 : begin
      sreg <= 16'h371d;
    end
    8'h24 : begin
      sreg <= 16'h3871;
    end
    8'h25 : begin
      sreg <= 16'h392a;
    end
    8'h26 : begin
      sreg <= 16'h3c78;
      // COM12 (0x3C) 0x78
    end
    8'h27 : begin
      sreg <= 16'h4d40;
    end
    8'h28 : begin
      sreg <= 16'h4e20;
    end
    8'h29 : begin
      sreg <= 16'h6900;
      // GFIX (0x69) 0x00
    end
    8'h2A : begin
      sreg <= 16'h6b4a;
    end
    8'h2B : begin
      sreg <= 16'h7410;
    end
    8'h2C : begin
      sreg <= 16'h8d4f;
    end
    8'h2D : begin
      sreg <= 16'h8e00;
    end
    8'h2E : begin
      sreg <= 16'h8f00;
    end
    8'h2F : begin
      sreg <= 16'h9000;
    end
    8'h30 : begin
      sreg <= 16'h9100;
    end
    8'h31 : begin
      sreg <= 16'h9600;
    end
    8'h32 : begin
      sreg <= 16'h9a00;
    end
    8'h33 : begin
      sreg <= 16'hb084;
    end
    8'h34 : begin
      sreg <= 16'hb10c;
    end
    8'h35 : begin
      sreg <= 16'hb20e;
    end
    8'h36 : begin
      sreg <= 16'hb382;
    end
    8'h37 : begin
      sreg <= 16'hb80a;
    end
    default : begin
      sreg <= 16'hffff;
    end
    endcase
  end


endmodule
