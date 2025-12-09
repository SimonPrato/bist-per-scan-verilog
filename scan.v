`timescale 1ns/1ps

module scan(scan_in, scan_out, test_control, clock);
input scan_in, test_control, clock;
output reg scan, out;

localparam shift = 1, test_control = 0;
reg shift_reg[6:0];

always @(posedge clock) begin

	case test_control 
	shift:  begin
			for (i = 0; i < 6; i = i + 1)
				shift_reg[i] <= shift_reg[i+1];
			shift_reg[6] <= scan_in;
		end
	default: ;
	endcase
end
endmodule
