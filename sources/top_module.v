`timescale 1ns/1ps

module top_module(
    input clock,
    input reset,
    input bist_start,
    input s,
    input dv,
    input l_in,
    input [1:0] test_in,
    output pass_nfail,
    output bist_end,
    output fz_L,
    output lclk,
    output [4:0] read_a,
    output [1:0] test_out
);

   wire init, running, finish;
   wire mode;
   wire scan_en;
   wire scan_in;
   wire scan_out;
   wire [15:0] signature;
   wire reset_lfsr;
   assign reset_lfsr = reset & finish;

// Controller outputs mode and running separately
   controller controller_1 (
    	.clock(clock),
    	.reset(reset),
    	.bist_start(bist_start),
    	.mode(mode),
    	.bist_end(bist_end),
    	.init(init),
    	.running(running),
    	.finish(finish)
   );

// Derived scan enable (your AND gate)
   assign scan_en = mode & running;

// LFSR drives scan_in only when scan_en is active
   lfsr lfsr_1 (
    	.scan_in(scan_in),
    	.clock(clock),
         .reset_lfsr(reset),
    	.mode(scan_en)
	);
    // CUT = scan netlist (cut_scan_syn.v) MUST provide scan ports
    // Optional: isolate functional inputs during scan mode (recommended)
    wire cut_s       = scan_en ? 1'b0  : s;
    wire cut_dv      = scan_en ? 1'b0  : dv;
    wire cut_l_in    = scan_en ? 1'b0  : l_in;
    wire [1:0] cut_test_in = scan_en ? 2'b00 : test_in;

    cut cut_1 (
        .clock(clock),
        .reset(reset),
        .s(cut_s),
        .dv(cut_dv),
        .l_in(cut_l_in),
        .test_in(cut_test_in),
        .fz_L(fz_L),
        .lclk(lclk),
        .read_a(read_a),
        .test_out(test_out),
        .scan_in(scan_in),
        .scan_out(scan_out),
        .scan_en(scan_en)
    );

    // MISR enabled only during running, cleared at init
    misr misr_1 (
        .clock(clock),
        .reset(reset),
        .init(init),
        .enable(running),
        .scan_out(scan_out),
        .fz_L(fz_L),
        .lclk(lclk),
        .read_a(read_a),
        .test_out(test_out),
        .signature(signature),
        .pass_nfail(pass_nfail)
    );

endmodule
