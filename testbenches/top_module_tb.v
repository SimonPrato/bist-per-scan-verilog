`timescale 1ns / 1ps

`define SCAN

module top_module_tb;

	reg clock, reset, bist_start, s, dv, l_in; 
    reg [1:0] test_in;
    wire [4:0] read_a;
    wire [1:0] test_out;

    top_module top_uut(
        .clock(clock),
        .reset(reset),
        .bist_start(bist_start),
        .s(s),
        .dv(dv),
        .l_in(l_in),
        .test_in(test_in),
        .pass_nfail(pass_nfail),
        .bist_end(bist_end),
        .fz_L(fz_L),
        .lclk(lclk),
        .read_a(read_a),
        .test_out(test_out)
    );

    initial begin
        clock = 0;
        bist_start = 0;
        reset = 1;
        s = 0;
        dv = 0;
        l_in = 0;
        test_in = 0;
        #15000 reset = 0;
        #1000 bist_start = 1;

        #28000000  $finish;
    end

    always
        begin
            #2000 clock = !clock;
        end



endmodule
