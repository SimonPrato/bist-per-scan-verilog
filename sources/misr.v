`timescale 1ns/1ps

module misr (
    input  clock,
    input  reset,
    input  enable,        // accumulates only during BIST running
    input  scan_out,
    input  fz_L,
    input  lclk,
    input  [4:0] read_a,
    input  [1:0] test_out,
    output reg [15:0] signature,
    output pass_nfail
);

    localparam SIGNATURE_BITS = 16;

    // Golden signature (do NOT change unless recomputed) (before it was: b0010011010110101)
    localparam [15:0] GOLDEN_SIGNATURE = 16'b0001100000011000;

    // 10-bit MISR input vector
    wire [9:0] data_in = {scan_out, fz_L, lclk, read_a, test_out};

    assign pass_nfail = (signature == GOLDEN_SIGNATURE);

    integer i;

    always @(posedge clock) begin
        if (reset) begin
            signature <= {SIGNATURE_BITS{1'b0}};
        end
        else if (enable) begin
            // MISR polynomial update (unchanged)
            for (i = 1; i < 10; i = i + 1) begin
                signature[i] <= signature[i] ^ data_in[9 - i] ^ signature[i - 1];
            end

            signature[0] <= signature[0] ^ data_in[9];

            for (i = 10; i < SIGNATURE_BITS; i = i + 1) begin
                signature[i] <= signature[i] ^ signature[i - 1];
            end
        end
        else ;
        // else: hold signature
    end

endmodule
