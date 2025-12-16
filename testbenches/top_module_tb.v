`timescale 1ns / 1ps

`define SCAN

module top_module_tb;

    reg clock, reset, bist_start;

    top_module uut(
        .clock(clock),
        .reset(reset),
	.bist_start(bist_start)
    );

    initial begin
	$dumpfile("dump.vcd"); $dumpvars;
        clock = 0;
	bist_start = 0;
        reset = 1;
    end

    always
	begin
        #2000 clock = !clock;
	end


    initial
        begin
        #15000 reset = 0;
        #1000 bist_start = 1;

	// Finish
        #28000000  $finish;
        end

endmodule
