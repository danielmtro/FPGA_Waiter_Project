interface dstream #(parameter N);  // Data stream interface. Parameter N is the bit width of the data.
	logic valid; // We use a handshake protocol just like in AXI-Stream
	logic ready;
	logic [N-1:0] data;
	
	modport in( // Module that takes the data as input.
		input  valid,
		output ready,
		input  data
	);
	modport out( // Module that outputs the data.
		output valid,
		input  ready,
		output data
	);
endinterface
