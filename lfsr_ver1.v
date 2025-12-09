`timescale 1ns/1ps

// 16-bit Fibonacci LFSR, maximal length
// Polynomial: x^16 + x^14 + x^13 + x^11 + 1
module lfsr16 (
    input  wire        clock,
    input  wire        reset,     // async global reset
    input  wire        init,      // sync re-seed at BIST start (from controller)
    input  wire        enable,    // shift when 1   (typically "running")
    output reg  [15:0] state,     // current LFSR contents (optional for debug)
    output wire        bit_out    // connect to scan_in of scan chain
);

    wire feedback;

    // taps: 15, 13, 12, 10 (bit 15 is MSB)
    assign feedback = state[15] ^ state[13] ^ state[12] ^ state[10];
    assign bit_out  = state[0];   // LSB drives scan_in

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // global reset – safe non-zero seed
            state <= 16'h0001;
        end else if (init) begin
            // start of BIST – re-seed to same non-zero value
            state <= 16'h0001;
        end else if (enable) begin
            // shift left, insert feedback at MSB
            state <= {state[14:0], feedback};
        end
        // else: hold state
    end

endmodule
