module misr(clock, reset, scan_out, fz_L, lclk, read_a, test_out, signature);
localparam SIGNATURE_BITS = 16;
input clock;
input reset;
input scan_out;
input fz_L;
input lclk;
input [4:0] read_a;
input [1:0] test_out;

output reg [SIGNATURE_BITS-1:0] signature;
integer i;

wire [9:0] data_in = {scan_out, fz_L, lclk, read_a, test_out};

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
