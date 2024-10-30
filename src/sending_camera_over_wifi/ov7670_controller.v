// File digital_cam_impl1/ov7670_controller.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
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

// Controller for the OV760 camera - transferes registers to the 
// camera over an I2C like bus
// no timescale needed

module ov7670_controller(
input wire clk,
input wire resend,
output wire config_finished,
output wire sioc,
inout wire siod,
output wire reset,
output wire pwdn,
output wire xclk
);




reg sys_clk = 1'b0;
wire [15:0] command;
wire finished;
wire taken;
wire send;  // device write ID; see datasheet of camera module;
parameter camera_address = 8'h42;

  assign config_finished = finished;
  assign send =  ~finished;
  i2c_sender Inst_i2c_sender(
      .clk(clk),
    .taken(taken),
    .siod(siod),
    .sioc(sioc),
    .send(send),
    .id(camera_address),
    .reg_(command[15:8]),
    .value(command[7:0]));

  assign reset = 1'b1;
  // Normal mode
  assign pwdn = 1'b0;
  // Power device up
  assign xclk = sys_clk;
  ov7670_registers Inst_ov7670_registers(
      .clk(clk),
    .advance(taken),
    .command(command),
    .finished(finished),
    .resend(resend));

  always @(posedge clk) begin
    sys_clk <=  ~sys_clk;
  end


endmodule
