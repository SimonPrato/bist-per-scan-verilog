`timescale 1ns/1ps

module tb_circuito08_vec;


// -----------------------------
// Parameters
// -----------------------------
	parameter VEC_W = 5;      // width of one vector
	parameter VEC_N = 30;   // max number of vectors in file
// -----------------------------	
// Inputs
// -----------------------------

	reg	clock;
	reg	reset;

	reg	s;
	reg 	dv;
	reg	l_in;
	reg [1:0] test_in;

// -----------------------------
// Outputs
// -----------------------------

	wire	fz_L;
	wire 	lclk;
	wire [4:0] read_a;
	wire [1:0] test_out;

// -----------------------------
// Vector memory
// -----------------------------
	reg [VEC_W-1:0] pattern_mem [0:VEC_N-1];
	integer i;

	circuito08 dut (
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

    // Clock generator (10ns period)
    always #2000 clock = ~clock;

    // -----------------------------
    // Load vectors from file
    // -----------------------------
    initial begin
        $readmemb("testbenches/circuito08.vec", pattern_mem);
    end

    // -----------------------------
    // Apply vectors
    // -----------------------------
    initial begin
        clock   = 0;
        reset   = 1;
        s       = 0;
        dv      = 0;
        l_in    = 0;
        test_in = 2'b00;

        // reset
        repeat (3) @(posedge clock);
        reset = 0;

        // apply vectors (1 per clock)
        for (i = 0; i < VEC_N; i = i + 1) begin
            {s, dv, l_in, test_in} = pattern_mem[i];
            @(posedge clock);

            $display("i=%0d in=%b | fz_L=%b lclk=%b read_a=%b test_out=%b",
                     i, pattern_mem[i], fz_L, lclk, read_a, test_out);
        end

        $display("DONE");
        $stop;
    end

endmodule
