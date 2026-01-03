`timescale 1ns/1ps

module tb_controller;

    reg clock;
    reg reset;
    reg bist_start;

    wire mode;
    wire bist_end;
    wire init;
    wire running;
    wire finish;

    // DUT: controller only
    controller dut (
        .clock(clock),
        .reset(reset),
        .bist_start(bist_start),
        .mode(mode),
        .bist_end(bist_end),
        .init(init),
        .running(running),
        .finish(finish)
    );

    // 4 us clock period
    always #2000 clock = ~clock;

    // Monitor controller outputs each clock
    always @(posedge clock) begin
        $display("t=%0t | rst=%b start=%b | mode=%b init=%b run=%b fin=%b end=%b",
                 $time, reset, bist_start, mode, init, running, finish, bist_end);
    end

    // Helper task: pulse bist_start for 1 clock
    task pulse_start;
    begin
        @(posedge clock);
        bist_start = 1'b1;
        @(posedge clock);
        bist_start = 1'b0;
    end
    endtask

    initial begin
        clock = 1'b0;
        reset = 1'b1;
        bist_start = 1'b0;

        // Release reset
        repeat (3) @(posedge clock);
        reset = 1'b0;

        // === Normal start ===
        $display("=== Normal BIST start ===");
        pulse_start();

        // Wait a bit
        repeat (10) @(posedge clock);

        // === Start while already running (should be ignored by edge detector) ===
        $display("=== Start pulse while controller is active ===");
        pulse_start();

        // Wait a bit
        repeat (10) @(posedge clock);

        // === Asynchronous disturbance: reset asserted briefly mid-sequence ===
        // Note: This is *not* synchronous to posedge clock on purpose.
        $display("=== Glitch reset mid-sequence ===");
        #1234;   // arbitrary time, not aligned to clock edge
        reset = 1'b1;
        #3000;
        reset = 1'b0;

        // After reset, try start again
        $display("=== Start after reset ===");
        pulse_start();

        // Wait until bist_end goes high (or timeout)
        repeat (15000) begin
            @(posedge clock);
            if (bist_end === 1'b1) begin
                $display("=== Controller reached bist_end ===");
                $finish;
            end
        end

        $display("TIMEOUT: bist_end never asserted");
        $finish;
    end

endmodule
