`timescale 1ns/1ps

module tb_circuito08;

    // DUT inputs
    reg clock;
    reg reset;
    reg s;
    reg dv;
    reg l_in;
    reg [1:0] test_in;

    // DUT outputs
    wire fz_L;
    wire lclk;
    wire [4:0] read_a;
    wire [1:0] test_out;

    // DUT
    circuito08 dut (
        .clock(clock),
        .reset(reset),
        .s(s),
        .dv(dv),
        .l_in(l_in),
        .test_in(test_in),
        .fz_L(fz_L),
        .lclk(lclk),
        .read_a(read_a),
        .test_out(test_out)
    );

    // Long clock period (required by assignment)
    // Period = 4000 ns (>2000)
    always #2000 clock = ~clock;

    // Vector memory: 30 vectors, 5 bits each
    localparam integer VEC_MAX = 30;
    reg [4:0] vec_mem [0:VEC_MAX-1];

    integer i;

    initial begin
        // Initialize
        clock   = 1'b0;
        reset   = 1'b1;
        s       = 1'b0;
        dv      = 1'b0;
        l_in    = 1'b0;
        test_in = 2'b00;

        // Load vectors from file
        // File lines: 01010, 10111, ...
        $readmemb("testbenches/circuito08.vec", vec_mem);

        // Reset for a few cycles
        repeat (3) @(posedge clock);
        reset = 1'b0;

        $display("vec# raw   | s dv l_in test_in | fz_L lclk read_a(dec/bin) test_out || cur nxt");

        // Apply vectors as a time sequence: ONE vector per clock
        for (i = 0; i < VEC_MAX; i = i + 1) begin
            // Map vector bits to inputs
            // vec[4]=s, vec[3]=dv, vec[2]=l_in, vec[1:0]=test_in
            s       = vec_mem[i][4];
            dv      = vec_mem[i][3];
            l_in    = vec_mem[i][2];
            test_in = vec_mem[i][1:0];

// Sample outputs on the next rising edge
            @(posedge clock);
            #1;

            $display("%0d    %05b | %b %b   %b    %02b     |  %b    %b    %0d/%05b       %02b    ||  %0d  %0d",
                     i, vec_mem[i],
                     s, dv, l_in, test_in,
                     fz_L, lclk, read_a, read_a, test_out,
                     dut.cur, dut.nxt);

        end

        $display("DONE.");
        $stop;
    end

endmodule
