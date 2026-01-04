`timescale 1ns/1ps

module top_module_tb;
    reg clock, reset, bist_start, s, dv, l_in;
    reg [1:0] test_in;

    wire pass_nfail;
    wire bist_end;
    wire cut_fz_L;
    wire cut_lclk;
    wire [4:0] cut_read_a;
    wire [1:0] cut_test_out;

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
        .cut_fz_L(cut_fz_L),
        .cut_lclk(cut_lclk),
        .cut_read_a(cut_read_a),
        .cut_test_out(cut_test_out)
    );

    // Clock: 4000 ns period (>2000 ns requirement)
    always #2000 clock = ~clock;

    parameter VEC_MAX = 30;
    reg [4:0] vec_mem [0:VEC_MAX-1];
    integer i;

    initial begin
        // init
        clock      = 1'b0;
        reset      = 1'b1;
        bist_start = 1'b0;   // NORMAL MODE: keep 0

        s       = 1'b0;
        dv      = 1'b0;
        l_in    = 1'b0;
        test_in = 2'b00;

        // load vectors (same file as CUT tb)
        $readmemb("testbenches/cut_testvectors.vec", vec_mem);
        if (^vec_mem[0] === 1'bX) begin
            $display("ERROR: vectors not loaded (check testbenches/cut_testvectors.vec)");
            $finish;
        end

        // reset sequence (deterministic)
        repeat (10) @(posedge clock);
        @(negedge clock);
        reset <= 1'b0;

        // settle 1 cycle after reset
        @(posedge clock);
        #1;

        // apply vectors: drive on negedge, sample on posedge
        for (i = 0; i < VEC_MAX; i = i + 1) begin
            @(negedge clock);
            s       <= vec_mem[i][4];
            dv      <= vec_mem[i][3];
            l_in    <= vec_mem[i][2];
            test_in <= vec_mem[i][1:0];

            @(posedge clock);
            #1;

            $display("%0d %05b | cut_fz_L=%b cut_lclk=%b cut_read_a=%0d cut_test_out=%02b",
                     i, vec_mem[i], fz_L, cut_lclk, cut_read_a, cut_test_out);
        end

        $display("TOP normal-mode vector simulation DONE");
        $finish;
    end

endmodule
