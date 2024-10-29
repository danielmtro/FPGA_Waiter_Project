// File digital_cam_impl1/ov7670_capture.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
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

// Captures the pixels data of each frame coming from the OV7670 camera and 
// Stores them in block RAM
// The length of href controls how often pixels are captive - (2 downto 0) stores
// one pixel every 4 cycles.
// "line" is used to control how often data is captured. In this case every forth 
// line
// no timescale needed

module ov7670_capture(
input wire pclk,
input wire vsync,
input wire href,
input wire [7:0] d,
output wire [16:0] addr,
output wire [11:0] dout,
output wire we
);




reg [15:0] d_latch = 1'b0;
reg [16:0] address = 1'b0;
reg [1:0] line = 1'b0;
reg [6:0] href_last = 1'b0;
reg we_reg = 1'b0;
reg href_hold = 1'b0;
reg latched_vsync = 1'b0;
reg latched_href = 1'b0;
reg [7:0] latched_d = 1'b0;

  assign addr = address;
  assign we = we_reg;
  assign dout = {d_latch[15:12],d_latch[10:7],d_latch[4:1]};
  always @(posedge pclk) begin
    if(we_reg == 1'b1) begin
      address <= (address) + 1;
    end
    // This is a bit tricky href starts a pixel transfer that takes 3 cycles
    //        Input   | state after clock tick   
    //         href   | wr_hold    d_latch           dout                we address  address_next
    // cycle -1  x    |    xx      xxxxxxxxxxxxxxxx  xxxxxxxxxxxx  x   xxxx     xxxx
    // cycle 0   1    |    x1      xxxxxxxxRRRRRGGG  xxxxxxxxxxxx  x   xxxx     addr
    // cycle 1   0    |    10      RRRRRGGGGGGBBBBB  xxxxxxxxxxxx  x   addr     addr
    // cycle 2   x    |    0x      GGGBBBBBxxxxxxxx  RRRRGGGGBBBB  1   addr     addr+1
    // detect the rising edge on href - the start of the scan line
    if(href_hold == 1'b0 && latched_href == 1'b1) begin
      case(line)
      2'b00 : begin
        line <= 2'b01;
      end
      2'b01 : begin
        line <= 2'b10;
      end
      2'b10 : begin
        line <= 2'b11;
      end
      default : begin
        line <= 2'b00;
      end
      endcase
    end
    href_hold <= latched_href;
    // capturing the data from the camera, 12-bit RGB
    if(latched_href == 1'b1) begin
      d_latch <= {d_latch[7:0],latched_d};
    end
    we_reg <= 1'b0;
    // Is a new screen about to start (i.e. we have to restart capturing
    if(latched_vsync == 1'b1) begin
      address <= {17{1'b0}};
      href_last <= {7{1'b0}};
      line <= {2{1'b0}};
    end
    else begin
      // If not, set the write enable whenever we need to capture a pixel
      if(href_last[2] == 1'b1) begin
        if(line[1] == 1'b1) begin
          we_reg <= 1'b1;
        end
        href_last <= {7{1'b0}};
      end
      else begin
        href_last <= {href_last[((6)) - 1:0],latched_href};
      end
    end
  end

  always @(negedge pclk) begin
    latched_d <= d;
    latched_href <= href;
    latched_vsync <= vsync;
  end


endmodule
