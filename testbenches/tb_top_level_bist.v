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

    integer file_handle;

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

    // Clock (period = 10us here; OK if assignment just says >2000ns)
    always #5000 clock = ~clock;

    initial begin
      file_handle = $fopen("reports/golden-signature.txt", "w");  // Opens file for writing
    end


    initial begin
        clock = 1'b0;
        reset = 1'b1;
        bist_start = 1'b0;
        s = 1'b0;
        dv = 1'b0;
        l_in = 1'b0;
        test_in = 2'b00;

        // Hold reset for a few *clock edges* (better than #time)
        repeat (3) @(posedge clock);
        reset <= 1'b0;

        // Clean 1-cycle bist_start pulse
        @(posedge clock);
        bist_start <= 1'b1;
        @(posedge clock);
        bist_start <= 1'b0;

        // Wait for BIST done
        wait (bist_end === 1'b1);

        // Let outputs settle (esp. gate-level)
        @(posedge clock);
        @(posedge clock);
	
        `ifdef MISR_SIGNATURE_EXISTS
            $fwrite(file_handle, "%d\n", dut.misr_signature);
        `else
            $display("misr_signature not available");
        `endif

        $display("PASS_NFAIL: %b", pass_nfail);

        $fclose(file_handle);
        #10000 $finish;
    end

endmodule
