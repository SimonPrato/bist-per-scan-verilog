`timescale 1ns/1ps

module tb_controller;

    // Controller inputs
    reg clock;
    reg reset;
    reg bist_start;

    // Determines if bist_end reached in simulation (flag)
    reg bist_end_reached;

    // Controller outputs
    wire bist_end;
    wire mode;
    wire init;
    wire running;
    wire finish;

    // CUT inputs
    reg s, dv, l_in;
    reg [1:0] test_in;

    // CUT outputs
    wire cut_fz_L;
    wire cut_lclk;
    wire [4:0] cut_read_a;
    wire [1:0] cut_test_out;

    // MISR output
    wire pass_nfail;

    top_level top_inst (
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

    // Clock pulse generation
    always #2000 clock = ~clock;

    // Monitor controller 
    always @(posedge clock) begin
        $display("t=%0t | reset=%b bist_start=%b | bist_end=%b",
                 $time, reset, bist_start, bist_end);
    end


    initial begin
        // controller inputs
        clock      = 1'b0;
        reset      = 1'b1;
        bist_start = 1'b0;   

        // CUT inputs
        s       = 1'b0;
        dv      = 1'b0;
        l_in    = 1'b0;
        test_in = 2'b00;

        // bist_end flag
        bist_end_reached = 1'b0;

        // Release reset
        reset = 1'b0;

        // Sequence one
        #4000 reset = 0;
        #4000 bist_start = 1;

        // wait for bist_end
        repeat (15000) begin
            @(posedge clock);
            if (bist_end === 1'b1) begin
                $display("=== Controller reached bist_end (Sequence one) ===");
                bist_end_reached = 1;
            end
        end

        // display error if bist_end not reached
        if (!bist_end_reached) begin
            $display("=== Controller did not reach bist_end (Sequence one) ===");
            $finish;
        end
        bist_end_reached = 0;

        // Sequence two
        #100 bist_start = 0;
        #4000 bist_start = 1;
        #8000 bist_start = 0;
        #8000 bist_start = 1;
        #4000 reset = 1;
        
        #4000 bist_start = 0;
        #4000 bist_start = 1;
        #4000 reset = 0;
        #8000 bist_start = 0;
        #8000 bist_start = 1;
        #4000 reset = 1;

        // check for bist_end
        repeat (15000) begin
            @(posedge clock);
            if (bist_end === 1'b1) begin
                $display("=== Controller reached bist_end (Sequence two) ===");
            end
        end

        // display error if bist_end not reached
        if (!bist_end_reached) begin
            $display("=== Controller did not reach bist_end (Sequence one) ===");
            $finish;
        end
        bist_end_reached = 0;

        $finish;
    end
endmodule
