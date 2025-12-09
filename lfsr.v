# Fibonacci LFSR

`timescale 1ns/1ps

module lfsr(scan_in, clock, reset);

output reg scan_in;
input clock;

reg shift_bits[6:0];

always @(posedge clock) begin
	if (reset == 1) begin
		for (i = 0; i < 7; i = i + 1)
			shift_bits[i] <= 0;
	end
	else begin
		for (i = 0; i < 6; i = i + 1)
			shift_bits[i] <= shift_bits[i+1];
		shift_bits[6] <= shift_bits[0] ^ shift_bits[6];
		scan_in <= shift_bits[0];
	end
end
endmodule
