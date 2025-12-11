`timescale 1ns/1ps

module top_level (
	input wire 	clock,
	input wire 	reset,
	input wire 	bist_start,
	
	// Previous primary inputs of CUT
	input wire 	s,
	input wire 	dv,
	input wire 	l_in,
	input wire [1:0] test_i,
	
	// Previous primary ouptputs of CUT
	output wire	fz_L,
	output wire	lclk,
	output wire [4:0] read_a,
	output wire [1:0] test_out,

	// BIST controller outputs
	output wire	bist_end,
	output reg 	pass_nfail
	);


// ------------------------------------------------------------
// 1) Controller outputs
// ------------------------------------------------------------
	wire mode;	// selects scan or normal mode
	wire init;	// resets LFSR and MISR at BIST start
	wire running;	// enables shifting (for LFSR and MISR)
	wire finish;	// indicates the end of BIST mode

	state_machine u_ctrl (
		clock     (clock),
		.reset     (reset),
        	.bist_start(bist_start),
        	.mode      (mode),
        	.bist_end  (bist_end),
        	.init      (init),
        	.running   (running),
        	.finish    (finish)
    	);
	
// ------------------------------------------------------------
// 2) Scan enable for CUT
// ------------------------------------------------------------
// Simple example: scan enabled only while BIST "running" in test mode
	wire scan_en = mode & running;
	
// ------------------------------------------------------------
// 3) LFSR (from lfsr_ver1.v) – drives scan_in
// ------------------------------------------------------------
	wire scan_in;
	
	lfsr16 u_lfsr (
		.clock(clock),  // clock is general for every module inside of the top_level
		.reset(reset),  // global (general reset)
		.init(init),	// BIST-only re-seed
		.enable(running), // BIST enables shifting while kept in running
		.state(),	// only if needed for debbuging
		.bit_out(scan_in) // drives scan chain input

// Needed to be added: circuit of a CUT scan
//This circuit will be obtained by starting the simulation SYN_scan_circuit
// After obtaining circuito08_scan.v with scan flip-flops, we can add the module and 
// add new codition, which will be meant by different states inside of the Makefile
// So that will help us define, if the current simulation is NORMAL mode or BIST mode


// ------------------------------------------------------------
// 5) MISR (from misr_ver2.v) – compresses scan_out + CUT outputs
//     CUT outputs: fz_L(1) + lclk(1) + read_a(5) + test_out(2) = 9 bits
//     + scan_out = 10 bits total into MISR
    // ------------------------------------------------------------
	wire [9:0] misr_data_in = {scan_out, fz_L, lclk, read_a, test_out};
	wire [9:0] misr_sig;

	misr10 u_misr (
        	.clock   (clock),
        	.reset   (reset),
        	.init    (init),          // clear signature at BIST start
        	.enable  (running),       // update only while BIST is running
        	.data_in (misr_data_in),
        	.sig     (misr_sig)
    	);

// ------------------------------------------------------------
// 6) Comparator vs. GOLDEN SIGNATURE → pass_nfail
// ------------------------------------------------------------
// TODO: replace 10'h000 with real golden signature from simulation
	localparam [9:0] GOLDEN_SIG = 10'h000;

	always @(posedge clock or posedge reset) begin
        	if (reset)
			pass_nfail <= 1'b0;
        	else if (finish)
// Compare MISR final signature against GOLDEN_SIG
			pass_nfail <= (misr_sig == GOLDEN_SIG);
    end

endmodule
