// File digital_cam_impl1/i2c_sender.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
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

// this is an entity used to sSend the commands to the OV7670 camera module
// over an I2C-like interface
// no timescale needed

module i2c_sender(
input wire clk,
inout reg siod,
output reg sioc,
output reg taken,
input wire send,
input wire [7:0] id,
input wire [7:0] reg_,
input wire [7:0] value
);




reg [7:0] divider = 8'b00000001;  // this value gives a 254 cycle pause before the initial frame is sent
reg [31:0] busy_sr = 1'b0;
reg [31:0] data_sr = 1'b1;

  always @(busy_sr, data_sr[31]) begin
    if(busy_sr[11:10] == 2'b10 || busy_sr[20:19] == 2'b10 || busy_sr[29:28] == 2'b10) begin
      siod <= 1'bZ;
    end
    else begin
      siod <= data_sr[31];
    end
  end

  always @(posedge clk) begin
    taken <= 1'b0;
    if(busy_sr[31] == 1'b0) begin
      sioc <= 1'b1;
      if(send == 1'b1) begin
        if(divider == 8'b00000000) begin
          data_sr <= {3'b100,id,1'b0,reg_,1'b0,value,1'b0,2'b01};
          busy_sr <= {3'b111,9'b111111111,9'b111111111,9'b111111111,2'b11};
          taken <= 1'b1;
        end
        else begin
          divider <= divider + 1;
          // this only happens on powerup
        end
      end
    end
    else begin
      case({busy_sr[32 - 1:32 - 3],busy_sr[2:0]})
      {3'b111,3'b111} : begin // start seq #1
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b1;
        end
        2'b01 : begin
          sioc <= 1'b1;
        end
        2'b10 : begin
          sioc <= 1'b1;
        end
        default : begin
          sioc <= 1'b1;
        end
        endcase
      end
      {3'b111,3'b110} : begin // start seq #2
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b1;
        end
        2'b01 : begin
          sioc <= 1'b1;
        end
        2'b10 : begin
          sioc <= 1'b1;
        end
        default : begin
          sioc <= 1'b1;
        end
        endcase
      end
      {3'b111,3'b100} : begin // start seq #3
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b0;
        end
        2'b01 : begin
          sioc <= 1'b0;
        end
        2'b10 : begin
          sioc <= 1'b0;
        end
        default : begin
          sioc <= 1'b0;
        end
        endcase
      end
      {3'b110,3'b000} : begin // end seq #1
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b0;
        end
        2'b01 : begin
          sioc <= 1'b1;
        end
        2'b10 : begin
          sioc <= 1'b1;
        end
        default : begin
          sioc <= 1'b1;
        end
        endcase
      end
      {3'b100,3'b000} : begin // end seq #2
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b1;
        end
        2'b01 : begin
          sioc <= 1'b1;
        end
        2'b10 : begin
          sioc <= 1'b1;
        end
        default : begin
          sioc <= 1'b1;
        end
        endcase
      end
      {3'b000,3'b000} : begin // Idle
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b1;
        end
        2'b01 : begin
          sioc <= 1'b1;
        end
        2'b10 : begin
          sioc <= 1'b1;
        end
        default : begin
          sioc <= 1'b1;
        end
        endcase
      end
      default : begin
        case(divider[7:6])
        2'b00 : begin
          sioc <= 1'b0;
        end
        2'b01 : begin
          sioc <= 1'b1;
        end
        2'b10 : begin
          sioc <= 1'b1;
        end
        default : begin
          sioc <= 1'b0;
        end
        endcase
      end
      endcase
      if(divider == 8'b11111111) begin
        busy_sr <= {busy_sr[32 - 2:0],1'b0};
        data_sr <= {data_sr[32 - 2:0],1'b1};
        divider <= {8{1'b0}};
      end
      else begin
        divider <= divider + 1;
      end
    end
  end


endmodule
