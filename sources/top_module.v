module top_module(clock, reset, bist_start);

input clock;
input bist_start;
input reset;

    lfsr lfsr_1(
        .clock(clock),
        .reset(reset),
	.scan_in(scan_in)
    );
    cut cut_1(
	.clock(clock), .reset(reset), .s(s),
           .dv(dv), .l_in(l_in), .test_in(test_in), .fz_L(fz_L),
           .lclk(lclk), .read_a(read_a), .test_out(test_out),
      .scan_in(scan_in), .scan_out(scan_out), .scan_en(mode));
    controller controller_1(.clock(clock), .reset(reset), .bist_start(bist_start), 
		.mode(mode), .bist_end(bist_end), .init(init), .running(running), 
		.finish(finish));
    misr misr_1(.clock(clock), .reset(reset), .scan_out(scan_out), .signature(signature));



endmodule
