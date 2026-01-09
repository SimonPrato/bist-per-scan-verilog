`timescale 1ns/1ps

module lfsr #(
	parameter integer MAX_BITS = 16,
	parameter [MAX_BITS-1:0] SEED = {MAX_BITS{1'b1}}   // default non-zero
)(
	output scan_bit,
	input  clock,
	input  reset,
	input  mode
);

	reg [MAX_BITS-1:0] shift_bits;
	assign scan_bit = shift_bits[MAX_BITS-1];

	always @(posedge clock) begin
		if (reset) begin
			shift_bits <= SEED;  // <<< seed here (NOT 0)
		end else if (mode) begin
			shift_bits <= {shift_bits[MAX_BITS-2:0], ~(shift_bits[15] ^ shift_bits[14] ^ shift_bits[12] ^ shift_bits[3])};
		end
        end
endmodule
