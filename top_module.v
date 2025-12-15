`timescale 1ns/1ps

module top_module(clock, reset);

    lfsr lfsr_1(
        .clock(clock),
        .reset(reset),
	.scan_in(scan_in)
    );
    cut cut_1(

    )

endmodule
