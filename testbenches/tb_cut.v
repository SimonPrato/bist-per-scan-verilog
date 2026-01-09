`timescale 1ns/1ps

module tb_cut;

// Inputs
	reg	clock;
	reg	reset;
	reg	s;
	reg	dv;
	reg	l_in;
	reg [1:0] test_in;

// Scan pins (only exist in scan-synth netlist)
	reg	scan_en;
	reg	scan_in;
	wire	scan_out;

// Outputs
	wire 	fz_L;
	wire	lclk;
	wire [4:0] read_a;
	wire [1:0] test_out;

// DUT instance
`ifdef SCAN
	cut cut_uut (
        	.clock(clock),
        	.reset(reset),
        	.s(s),
        	.dv(dv),
        	.l_in(l_in),
        	.test_in(test_in),
        	.fz_L(fz_L),
        	.lclk(lclk),
        	.read_a(read_a),
        	.test_out(test_out),
        	.scan_en(scan_en),
        	.scan_in(scan_in),
        	.scan_out(scan_out)
    		);
`else
	cut cut_uut (
        	.clock(clock),
        	.reset(reset),
        	.s(s),
        	.dv(dv),
        	.l_in(l_in),
        	.test_in(test_in),
        	.fz_L(fz_L),
        	.lclk(lclk),
        	.read_a(read_a),
        	.test_out(test_out)
    		);
`endif

// Clock: 4000 ns period
	always #2000 clock = ~clock;

// Vectors: 30 vectors, Separation of the bits [4]=s, [3]=dv, [2]=l_in, [1:0]=test_in
	parameter VEC_MAX = 30;
	reg [4:0] vec_mem [0:VEC_MAX-1];
	integer i;

	initial begin

// Init
	clock   = 1'b0;
	reset   = 1'b1;

	s       = 1'b0;
	dv      = 1'b0;
	l_in    = 1'b0;
	test_in = 2'b00;

// Force functional mode (scan netlist)
	scan_en = 1'b0;
	scan_in = 1'b0;

// Load vectors
	$readmemb("testbenches/cut_testvectors.vec", vec_mem);

// Fail fast if vectors not loaded
	if (^vec_mem[0] === 1'bX) begin
	    $display("ERROR: vectors not loaded (check path testbenches/cut_testvectors.vec)");
	    $finish;
	end

// Hold reset long enough for both RTL and netlist
	repeat (10) @(posedge clock);

// Sets reset on negedge for next posedge clock beeing stable
	@(negedge clock);
	reset <= 1'b0;

// 1 full-cycle settling all inputs with 0
	s       <= 1'b0;
	dv      <= 1'b0;
        l_in    <= 1'b0;
	test_in <= 2'b00;
	scan_en <= 1'b0;
	scan_in <= 1'b0;

	@(posedge clock);
	#1;

// Apply vectors: drive on negedge, sample on next posedge
	for (i = 0; i < VEC_MAX; i = i + 1) begin
	    @(negedge clock);
	    s       <= vec_mem[i][4];
	    dv      <= vec_mem[i][3];
	    l_in    <= vec_mem[i][2];
	    test_in <= vec_mem[i][1:0];

	    @(posedge clock);
	    #1;

		$display("%0d %05b | fz_L=%b lclk=%b read_a=%0d test_out=%02b",
			i, vec_mem[i], fz_L, lclk, read_a, test_out);
	end

	$display("CUT vector simulation DONE");
	$finish;
    end

endmodule
