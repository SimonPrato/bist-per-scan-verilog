`timescale 1ns/1ps

module top_module(
	input  wire        clock,            
	input  wire        reset,           
	input  wire        bist_start,     
	input  wire        s,             
	input  wire        dv,           
	input  wire        l_in,        
	input  wire [1:0]  test_in,    
	output wire        pass_nfail,
	output wire        bist_end, 
	output wire        cut_fz_L,
	output wire        cut_lclk,         
	output wire [4:0]  cut_read_a,      
	output wire [1:0]  cut_test_out    
);

// Internal control signals
	wire controller_init;
	wire controller_running;
	wire controller_finish;
	wire controller_mode;           // Scan and functional mode
    
// Scan chain signals	
	wire scan_enable;
	wire scan_chain_in;
	wire scan_chain_out;
wire [15:0] misr_signature;
    
// Reset synchronization for LFSR/MISR
	wire lfsr_misr_reset;
	assign lfsr_misr_reset = reset | controller_init;
    
// BIST Controller
controller controller_inst (
	.clock(clock),
	.reset(reset),
	.bist_start(bist_start),
	.mode(controller_mode),
	.bist_end(bist_end),
	.init(controller_init),
	.running(controller_running),
	.finish(controller_finish)
);
    
// Scan enable generation
	assign scan_enable = controller_mode & controller_running;
    
// LFSR (pseudo-ranom generator, 16-bit)
lfsr #(.MAX_BITS(16), .SEED(16'h5A5A)) lfsr_inst (
	.scan_bit(scan_chain_in),
	.clock(clock),
	.reset(lfsr_misr_reset),
	.mode(scan_enable)
);
    
// CUT inputs multiplexing (isolate during scan)
	wire cut_s       = scan_enable ? 1'b0 : s;
	wire cut_dv      = scan_enable ? 1'b0 : dv;
	wire cut_l_in    = scan_enable ? 1'b0 : l_in;
	wire [1:0] cut_test_in = scan_enable ? 2'b00 : test_in;

// Circuit Under Test (CUT)
cut cut_inst (
	.clock(clock),
	.reset(reset),
	.s(cut_s),
	.dv(cut_dv),
	.l_in(cut_l_in),
	.test_in(cut_test_in),
	.fz_L(cut_fz_L),
	.lclk(cut_lclk),
	.read_a(cut_read_a),
	.test_out(cut_test_out),
	.scan_in(scan_chain_in),
	.scan_out(scan_chain_out),
	.scan_en(scan_enable)
);

// Multiple Input Signature Register (MISR)
misr misr_inst (
	.clock(clock),
	.reset(lfsr_misr_reset),
	.enable(scan_enable),
	.scan_out(scan_chain_out),
	.signature(misr_signature),
	.pass_nfail(pass_nfail),
	.fz_L(cut_fz_L),
	.lclk(cut_lclk),
	.read_a(cut_read_a),
	.test_out(cut_test_out)
);

endmodule

