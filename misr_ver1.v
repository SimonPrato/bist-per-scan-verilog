`timescale 1ns/1ps

// 16-bit MISR (Multiple-Input Signature Register)
// Uses same polynomial as LFSR: x^16 + x^14 + x^13 + x^11 + 1
module misr16 #(
    parameter IN_WIDTH = 8    // number of bits being compressed
)(
    input  wire                clock,
    input  wire                reset,     // async global reset
    input  wire                init,      // sync clear at BIST start
    input  wire                enable,    // update when 1   (typically "running")
    input  wire [IN_WIDTH-1:0] data_in,   // bits to fold in each cycle
    output reg  [15:0]         sig        // current signature
);

    wire       feedback;
    reg [15:0] next;
    integer    i;

    // feedback from current signature
    assign feedback = sig[15] ^ sig[13] ^ sig[12] ^ sig[10];

    // combinational next-state logic
    always @* begin
        // bit 0: feedback XOR first data bit (if it exists)
        next[0] = feedback ^ (IN_WIDTH > 0 ? data_in[0] : 1'b0);

        // bits 1..15: shift and optionally XOR data_in[i]
        for (i = 1; i < 16; i = i + 1) begin
            if (i < IN_WIDTH)
                next[i] = sig[i-1] ^ data_in[i];
            else
                next[i] = sig[i-1];
        end
    end

    // register update
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            sig <= 16'b0;
        end else if (init) begin
            // clear signature at start of BIST
            sig <= 16'b0;
        end else if (enable) begin
            sig <= next;
        end
        // else: hold sig
    end

endmodule
