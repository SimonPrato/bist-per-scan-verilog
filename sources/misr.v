module misr(clock, reset, scan_out, signature);
localparam BITS = 10;
input clock;
input reset;
input wire scan_out;

output reg [BITS-1:0] signature;

wire xor_comb = signature[9] ^ signature[6] ^ scan_out;

always @(posedge clock) begin
	if (reset) begin
		signature <= 0;
	end
	else begin
        signature <= {signature[BITS-2:0], 1'b0} ^ {9'b0, xor_comb};
	end	
end

endmodule
