module sensor_driver_tb();

parameter CLK_PERIOD = 20;

logic clk;
logic echo;
logic trigger;
logic start;
logic reset;
logic [7:0] distance;

sensor_driver u0(
	.clk(clk),
	.echo(echo),
	.measure(start),
	.rst(reset),
	.trig(trigger),
	.distance(distance)

);

initial clk = 1'b0;

always begin
    #10 
	 clk = ~clk;
end
  
 initial begin

	reset = 1;
	start = 0;
	distance = 0;

	#(1 * CLK_PERIOD)
	reset = 0; 
	start = 1;
	
	#(1 * CLK_PERIOD)
	start = 0;
	
	#(100 * CLK_PERIOD)
	echo = 1;
	#(100000 * CLK_PERIOD)
	
	#(1 * CLK_PERIOD)
	echo = 0;
	
	#(10 * CLK_PERIOD)

	#(1 * CLK_PERIOD)
	start = 1;
	
	#(1 * CLK_PERIOD)
	start = 0;
	
	#(100 * CLK_PERIOD)
	echo = 1;
	#(100000 * CLK_PERIOD)
	
	#(1 * CLK_PERIOD)
	echo = 0;
	
	#(10 * CLK_PERIOD)

	$finish();
  end

endmodule 
