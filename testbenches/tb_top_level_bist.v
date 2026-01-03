`timescale 1ns/1ps

module tb_top_level_bist;

    reg clock;
    reg reset;
    reg bist_start;
    reg s, dv, l_in;
    reg [1:0] test_in;

    wire pass_nfail;
    wire bist_end;
    wire fz_L;
    wire lclk;
    wire [4:0] read_a;
    wire [1:0] test_out;

    // DUT
    top_module dut (
        .clock(clock),
        .reset(reset),
        .bist_start(bist_start),
        .s(s),
        .dv(dv),
        .l_in(l_in),
        .test_in(test_in),
        .pass_nfail(pass_nfail),
        .bist_end(bist_end),
        .fz_L(fz_L),
        .lclk(lclk),
        .read_a(read_a),
        .test_out(test_out)
    );

    // Clock: 4 us period
    always #2000 clock = ~clock;

    initial begin
        // Init
        clock = 0;
        reset = 1;
        bist_start = 0;
        s = 0;
        dv = 0;
        l_in = 0;
        test_in = 0;

        // Release reset
        repeat (3) @(posedge clock);
        reset = 0;

        // Start BIST (one clean pulse)
        @(posedge clock);
        bist_start = 1;
        @(posedge clock);
        bist_start = 0;

        // Wait until BIST finishes
        wait (bist_end == 1);

        // Report result
        if (pass_nfail)
            $display("BIST PASSED");
        else
            $display("BIST FAILED");

        #1000;

// Wait for BIST to finish
	wait (bist_end == 1'b1);

// Give one extra clock to stabilize
	@(posedge clock);

// Print PASS_NFAIL and BIST_END
	$display("====================================");
	$display("BIST_END=%b PASS_NFAIL=%b", bist_end, pass_nfail);
	$display("====================================");

        $finish;
    end

endmodule
