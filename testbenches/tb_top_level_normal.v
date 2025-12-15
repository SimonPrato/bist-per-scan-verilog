`timescale 1ns/1ps

module tb_top_level_normal;

	reg 		clock, reset, bist_start;
	reg 		s, dv, l_in;
	reg [1:0] 	test_in;

    	wire		fz_L;
	wire	 	lclk;
    	wire [4:0] 	read_a;
    	wire [1:0] 	test_out;
	wire 		bist_end;
	wire 		pass_nfail;

   top_level dut (
	.clock(clock),
	.reset(reset),
	.bist_start(bist_start),
	.s(s),
	.dv(dv),
	.l_in(l_in),
	.test_in(test_in),
	.fz_L(fz_L),
	.lclk(lclk),
	.read_a(read_a),
	.test_out(test_out),
	.bist_end(bist_end),
	.pass_nfail(pass_nfail)
	);

// VERY long clock for AMS guidance (you used #2000 earlier)
	always #2000 clock = ~clock;

	localparam integer 	VEC_MAX = 64;
	reg [4:0] 		vec_mem [0:VEC_MAX-1];
	integer 		i;

	initial begin
	clock = 1'b0;
	reset = 1'b1;
	bist_start = 1'b0; // IMPORTANT: keep BIST off for normal-mode compare
	s = 1'b0; dv = 1'b0; l_in = 1'b0; test_in = 2'b00;

	$readmemb("testbenches/circuito08.vec", vec_mem);

	repeat (5) @(posedge clock);
	
	@(negedge clock);
	reset = 1'b0;


	@(posedge clock);
	$display("vec# raw   | s dv l_in test_in | fz_L lclk read_a(dec/bin) test_out");
	for (i = 0; i < VEC_MAX; i = i + 1) begin
	   if (vec_mem[i] === 5'bxxxxx) begin
		$display("DONE (end marker) at %0d", i);
		$finish;
	end

// Apply vector
	@(negedge clock);
	s       = vec_mem[i][4];
	dv      = vec_mem[i][3];
	l_in    = vec_mem[i][2];
	test_in = vec_mem[i][1:0];

	@(posedge clock);
	#1;

		$display("%0d    %05b | %b %b   %b    %02b     |  %b    %b    %0d/%05b       %02b", 
			i, vec_mem[i], s, dv, l_in, test_in, fz_L, lclk, read_a, read_a, test_out);
	end

	$display("DONE (hit VEC_MAX=%0d)", VEC_MAX);
	$finish;
   end

endmodule
