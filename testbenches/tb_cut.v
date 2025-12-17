`timescale 1ns/1ps

module tb_cut;

    reg        clock;
    reg        reset;
    reg        s;
    reg        dv;
    reg        l_in;
    reg [1:0]  test_in;

    wire        fz_L;
    wire        lclk;
    wire [4:0]  read_a;
    wire [1:0]  test_out;

    cut cut_uut (
        .clock    (clock),
        .reset    (reset),
        .s        (s),
        .dv       (dv),
        .l_in     (l_in),
        .test_in  (test_in),
        .fz_L     (fz_L),
        .lclk     (lclk),
        .read_a   (read_a),
        .test_out (test_out)
    );

    always #2000 clock = ~clock;

    initial begin
        clock   = 1'b0;
        reset   = 1'b1;
        s       = 1'b0;
        dv      = 1'b0;
        l_in    = 1'b0;
        test_in = 2'b00;

    end

    initial
        begin
        #5000 reset = 0;

        #28000 $finish;
    end
        

endmodule

