module top_module(
    input clock,
    input reset,
    input bist_start,
    input s,
    input dv,
    input l_in,
    input [1:0] test_in,
    output pass_nfail,
    output bist_end,
    output fz_L,
    output lclk,
    output [4:0]read_a),
    output test_out
);

wire scan_in;
wire scan_out;
wire fz_L;
wire lclk;
wire [4:0] read_a;
wire [1:0] test_out;
wire mode, bist_end, init, running, finish;
wire [15:0] signature;

lfsr lfsr_1 (
.clock(clock),
.reset(reset),
.scan_in(scan_in),
.mode(mode)
);

cut cut_1 (
.clock(clock),
.reset(reset),
.s(s),
.dv(dv),
.l_in(l_in),
.test_in(test_in),
.fz_L(fz_L),
.lclk(lclk),
.read_a(read_a),
.test_out(test_out),
.scan_in(scan_in),
.scan_out(scan_out),
.scan_en(mode)
);

controller controller_1 (
.clock(clock),
.reset(reset),
.bist_start(bist_start),
.mode(mode),
.bist_end(bist_end),
.init(init),
.running(running),
.finish(finish)
);

misr misr_1 (
.clock(clock),
.reset(reset),
.scan_out(scan_out),
.fz_L(fz_L),
.lclk(lclk),
.read_a(read_a),
.test_out(test_out),
.signature(signature),
.pass_nfail(pass_nfail)
);

endmodule

