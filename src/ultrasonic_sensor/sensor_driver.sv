// sensor_driver based on timing diagram:
// user sends a trigger signal which lasts 10us, and expects an echo signal back to the module
// The Echo is a distance object that is pulse width and the range in proportion.
// You can calculate the range through the time interval between sending trigger signal and receiving echo signal

module sensor_driver#(parameter ten_us = 10'd500)(
  input clk,
  input rst,
  input measure,
  input echo,
  output trig,
  output [7:0] distance);
  
  localparam IDLE = 3'b000,
          TRIGGER = 3'b010,
             WAIT = 3'b011,
        COUNTECHO = 3'b100,
		  DISPLAY_DISTANCE = 3'b101;
		  
  wire inIDLE, inTRIGGER, inWAIT, inCOUNTECHO, inDISPLAY;
  reg [9:0] counter;
  reg [21:0] distanceRAW = 0; // cycles in COUNTECHO
  reg [31:0] distanceRAW_in_cm = 0;
  wire trigcountDONE, counterDONE;
  
  logic [2:0] state;
  logic ready;   

  //Ready
  assign ready = inIDLE;
  
  //Decode states
  assign inIDLE = (state == IDLE);
  assign inTRIGGER = (state == TRIGGER);
  assign inWAIT = (state == WAIT);
  assign inCOUNTECHO = (state == COUNTECHO);
  assign inDISPLAY = (state == DISPLAY_DISTANCE);

  //State transactions
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state <= IDLE;
        end
      else
        begin
          case(state)
            IDLE:
              begin
                state <= (measure & ready) ? TRIGGER : state;
              end
            TRIGGER:
              begin
                state <= (trigcountDONE) ? WAIT : state;
              end
            WAIT:
              begin
                state <= (echo) ? COUNTECHO : state;
              end
            COUNTECHO:
              begin
                state <= (echo) ? state : DISPLAY_DISTANCE;
              end
				DISPLAY_DISTANCE:
					begin
						state <= IDLE;
					end
          endcase
          
        end
    end
  
  //Trigger
  assign trig = inTRIGGER;
  
  //Counter
  always@(posedge clk)
    begin
      if(inIDLE)
        begin
          counter <= 10'd0;
        end
      else
        begin
          counter <= counter + {9'd0, (|counter | inTRIGGER)};
        end
    end
  assign trigcountDONE = (counter == ten_us);

  //Get distance
  always@(posedge clk)
    begin
      if(inWAIT) begin
        distanceRAW <= 22'd0;
      end else
        distanceRAW <= distanceRAW + {21'd0, inCOUNTECHO};
		  
    end

  // to calculate distance in cm
  // range = high level time * velocity (340M/S) / 2
  // 340m/s = 0.000034cm/ns = 0.00068cm/cycle
  // range = 0.00068/2 = 0.00034cm/cycle
  // using fixedpoint python library we can convert 0.000034 to fixed point binary with 8 int and 24 frac bits by writing the code below
  // import fixedpoint
  // print(fixedpoint.FixedPoint(0.00034, signed=True, m=8, n=24)) # Signed with 8 integer bits and 24 fractional bits
	 
	always @(posedge clk) begin
		if(inDISPLAY) begin
			distanceRAW_in_cm <= distanceRAW * 32'h1648;
		end
	end
	
	assign distance = distanceRAW_in_cm[31:24];

endmodule

// timer used to measure distance at 250ms intervals - not used in top level
module refresher250ms(
  input clk,
  input en,
  output measure);
  reg [24:0] counter;

  assign measure = (counter == 25'd1);

  always@(posedge clk)
    begin
      if(~en | (counter == 25'd12_500_000))
        counter <= 25'd0;
      else
        counter <= 25'd1 + counter;
    end
endmodule
