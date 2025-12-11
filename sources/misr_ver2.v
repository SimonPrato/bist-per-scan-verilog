`timescale 1ns/1ps

module misr10 (
	input wire	clock,
	input wire	reset,
	input wire 	enable, // From BIST controller (running)
	input wire 	init, // From BIST controller (init)
	
	input wire [9:0] data_in, // {scan_out, fz_L, lclk, read_a[4:0], test_out[1:0]}
	output reg [9:0] sig
	);

always @(posedge clock or posedge reset) begin
	if (reset) begin
		sig <= 10'b0;
	end else if (init) begin
		sig <= 10'b0; //We start with a zero signature
	end else if (enable) begin
		// Enabling MISR
		sig[0] <= sig[9] ^ data_in[0];
		sig[1] <= sig[9] ^ sig[1] ^ data_in[1];
		sig[2] <= sig[1] ^ data_in[2];
		sig[3] <= sig[2] ^ data_in[3];
		sig[4] <= sig[3] ^ data_in[4];
		sig[5] <= sig[4] ^ data_in[5];
		sig[6] <= sig[5] ^ data_in[6];
		sig[7] <= sig[6] ^ data_in[7];
		sig[8] <= sig[7] ^ data_in[8];
		sig[9] <= sig[8] ^ data_in[9];
	end
end
endmodule
		
