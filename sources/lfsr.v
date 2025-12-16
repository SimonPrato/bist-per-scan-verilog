module lfsr(scan_in, clock, reset, mode);

output reg scan_in;
input clock;
input reset;
input mode;

localparam MAX_BITS = 8;
reg [MAX_BITS-1:0] shift_bits;


always @(posedge clock) begin
	if (reset == 1) begin
		shift_bits <= 0;
		scan_in <= 0;
    end
	else if (mode) begin
		shift_bits <= {shift_bits[MAX_BITS-2:0],
                       ~(shift_bits[0] ^ shift_bits[2] ^ shift_bits[3] ^ shift_bits[4])};
		scan_in <= shift_bits[MAX_BITS-1];
	end
	else ;
end
endmodule
