`timescale 1ns/1ps

module tb_lfsr16;

	reg clock;
	reg reset;
	reg init;
	reg enable;

	wire [15:0] state;
	wire bit_out;

	lfsr16 dut(
		.clock(clock),
		.reset(reset),
		.init(init),
		.enable(enable),
		.state(state),
		.bit_out(bit_out)
		);

	always #5 clock = ~clock;
		
	integer i;
	
	initial begin
		$display("=== LFSR16 TESTBENCH Check ===");

		clock = 0;
		reset = 1;
		init = 0;
		enable = 0;

		#20
		
		reset = 0;

		//Apply the init pulse
		init = 1;
		#10
		init = 0;

		//Enable the shifting of the LFSR
		enable = 1;
		//Create a loop, which will print 50 states of the lfsr
		for (i = 0; i < 16; i = i + 1) begin
			@(posedge clock);
			$display("cycle %0d : state = %h bit_out = %b", i, state, bit_out);
		end
		$stop;
	end

endmodule	
