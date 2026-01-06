`timescale 1ns / 1ps

module tb_controller;

    reg clock, reset, bist_start;
    wire mode, bist_end, init, running, finish;

    controller dut(
        .clock(clock),
        .reset(reset),
        .bist_start(bist_start),
        .mode(mode),
        .bist_end(bist_end),
        .init(init),
        .running(running),
        .finish(finish)
    );

    initial begin
        clock = 0;
        reset = 1;
        bist_start = 0;
    end

    always
        #50 clock = !clock;

	// One sequence takes 9 µs
    initial
        begin
        // Sequence one
        #100 reset = 0;
        #100 bist_start = 1;

        // Sequence two
        #9700 bist_start = 0;
        #100 bist_start = 1;
        #200 bist_start = 0;
        #200 bist_start = 1;
        #100 reset = 1;

        // Sequence three
        #100 bist_start = 0;
        #100 bist_start = 1;
        #100 reset = 0;
        #200 bist_start = 0;
        #200 bist_start = 1;
        #100 reset = 1;

        // Finish
        #300  $finish;
    end

endmodule
