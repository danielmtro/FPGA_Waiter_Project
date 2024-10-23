module colour_detect_tb;

	logic       clk;
	logic[11:0] data_in = 0;
	logic ready;

	integer count;
	
	logic eop, sop, output_flag;
	 
	 colour_detect #(.THRESHOLD(100)) DUT (
		.clk(clk),
		.pixel(data_in),
		.eop(eop),
		.sop(sop),
		.colour_flag(output_flag)
	 );
	 
	 localparam CLK_T = 20;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
		  data_in = 12'b000100010001;
		  count = 0;
    end
	 
	
	 initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
		  
		  wait(ready) begin
				#100;
				$finish();
		  end
		  
	 end
	 
	 always_ff @(posedge clk) begin
		if(count == 100) begin
			count <= 0;
		end
		else begin
			count <= count + 1;
		end
			
	 end
	 
	 
	 always_comb begin
		sop = 0;
		eop = 0;
		
		if(count == 0) begin
			sop = 1;
		end
		
		
		if(count == 100) begin 
			eop = 1;
			ready = 1;
		end
		
	 end


 
	 
endmodule 