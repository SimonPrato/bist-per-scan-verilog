`timescale 1ns/1ps

module tb_top_level_bist;
    reg clock;
    reg reset;
    reg bist_start;
    reg s, dv, l_in;
    reg [1:0] test_in;

    wire pass_nfail;
    wire bist_end;
    wire cut_fz_L;
    wire cut_lclk;
    wire [4:0] cut_read_a;
    wire [1:0] cut_test_out;

    // DUT
    top_module dut (
        .clock(clock),
        .reset(reset),
        .bist_start(bist_start),
        .s(s),
        .dv(dv),
        .l_in(l_in),
        .test_in(test_in),
        .pass_nfail(pass_nfail),
        .bist_end(bist_end),
        .cut_fz_L(cut_fz_L),
        .cut_lclk(cut_lclk),
        .cut_read_a(cut_read_a),
        .cut_test_out(cut_test_out)
    );

    // Clock: 4 us period
    always #5000 clock = ~clock;

    initial begin
        // Init
        clock = 0;
        reset = 1;
        bist_start = 0;
        s = 0;
        dv = 0;
        l_in = 0;
        test_in = 0;

        // Release reset
        #30000 reset = 0;

        // Start BIST (one clean pulse)
        #100 bist_start = 1;

        wait (bist_end == 1'b1);
        #10000 $finish;
    end

endmodule
