module misr(clock, reset, scan_out, fz_L, lclk, read_a, test_out, signature, pass_nfail);
localparam SIGNATURE_BITS = 16;
input clock;
input reset;
input scan_out;
input fz_L;
input lclk;
input [4:0] read_a;
input [1:0] test_out;

output reg [SIGNATURE_BITS-1:0] signature;
output pass_nfail;

integer i;

reg [15:0] golden_signature = 16'b0010011010110101;
wire [9:0] data_in = {scan_out, fz_L, lclk, read_a, test_out};

assign pass_nfail = (signature == golden_signature);

always @(posedge clock) begin
	if (reset) begin
		signature <= 0;
	end
	else begin
	for (i = 1; i < 10; i = i + 1) begin
            signature[i] <= signature[i] ^ data_in[9 - i] ^ signature [i - 1]; 
	end
	signature[0] <= signature[0] ^ data_in[9];
	for(i = 10; i < SIGNATURE_BITS-1; i = i + 1) begin
	signature[i] <= signature[i] ^ signature [i-1];
	end
        end
        	
end

endmodule
