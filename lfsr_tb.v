`timescale 1ns / 1ps

module lfsr_tb;

    reg clock, reset; 
    wire scan_in;

    lfsr uut(
        .clock(clock),
        .reset(reset),
	.scan_in(scan_in)
    );

    initial begin
	$dumpfile("dump.vcd"); $dumpvars;
        clock = 0;
        reset = 1;
    end

    always
        #50 clock = !clock;

	// One sequence takes 9 µs
    initial
        begin
        #100 reset = 0;

	// Finish
        #300  $finish;
        end

endmodule
