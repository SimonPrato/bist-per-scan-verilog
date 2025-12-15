`timescale 1ns/1ps

module top_level (
    input  wire        clock,
    input  wire        reset,
    input  wire        bist_start,

    // Previous primary inputs of CUT
    input  wire        s,
    input  wire        dv,
    input  wire        l_in,
    input  wire [1:0]  test_in,

    // Previous primary outputs of CUT
    output wire        fz_L,
    output wire        lclk,
    output wire [4:0]  read_a,
    output wire [1:0]  test_out,

    // BIST controller outputs / observables
    output wire        bist_end,
    output reg         pass_nfail
);

    // ------------------------------------------------------------
    // 1) Controller outputs
    // ------------------------------------------------------------
    wire mode;     // "test mode" from controller
    wire init;     // seed/clear at BIST start
    wire running;  // BIST active window
    wire finish;   // end pulse/state

    state_machine u_ctrl (
        .clock      (clock),
        .reset      (reset),
        .bist_start (bist_start),
        .mode       (mode),
        .bist_end   (bist_end),
        .init       (init),
        .running    (running),
        .finish     (finish)
    );

    // ------------------------------------------------------------
    // 2) Scan sequencer: SHIFT 13 cycles, then CAPTURE 1 cycle
    //    Your scandef says chain length = 13.
    // ------------------------------------------------------------
    localparam integer SHIFT_CYCLES = 13;

    reg  phase_shift;            // 1=SHIFT, 0=CAPTURE
    reg  [3:0] shift_cnt;        // enough for 0..12

    wire bist_active = mode & running;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            phase_shift <= 1'b1;
            shift_cnt   <= 4'd0;
        end else if (init) begin
            // Start BIST with a clean SHIFT phase
            phase_shift <= 1'b1;
            shift_cnt   <= 4'd0;
        end else if (!bist_active) begin
            // Not in BIST -> park in SHIFT-ready state
            phase_shift <= 1'b1;
            shift_cnt   <= 4'd0;
        end else begin
            // BIST active: alternate SHIFT(13) -> CAPTURE(1)
            if (phase_shift) begin
                if (shift_cnt == SHIFT_CYCLES-1) begin
                    phase_shift <= 1'b0;   // next cycle = CAPTURE
                    shift_cnt   <= 4'd0;
                end else begin
                    shift_cnt   <= shift_cnt + 4'd1;
                end
            end else begin
                // CAPTURE for exactly 1 cycle
                phase_shift <= 1'b1;
                shift_cnt   <= 4'd0;
            end
        end
    end

    // Scan enable: ONLY during SHIFT phase of BIST
    wire scan_en = bist_active & phase_shift;

    // ------------------------------------------------------------
    // 3) LFSR -> scan_in (SHIFT-only)
    // ------------------------------------------------------------
    wire scan_in;
    wire [15:0] lfsr_state_unused;

    wire lfsr_en = bist_active & phase_shift;  // SHIFT-only

    lfsr16 u_lfsr (
        .clock   (clock),
        .reset   (reset),
        .init    (init),
        .enable  (lfsr_en),
        .state   (lfsr_state_unused),
        .bit_out (scan_in)
    );

    // ------------------------------------------------------------
    // 4) CUT primary-input muxing
    //    In BIST we hold functional PIs to constants to avoid fighting scan.
    //    You can tune these constants later to improve coverage.
    // ------------------------------------------------------------
	localparam BIST_S = 1'b1;
	localparam BIST_DV = 1'b1;
	localparam BIST_LIN = 1'b0;
	localparam [1:0] BIST_TESTIN = 2'b00;

	wire s_cut       = bist_active ? BIST_S      : s;
	wire dv_cut      = bist_active ? BIST_DV     : dv;
	wire l_in_cut    = bist_active ? BIST_LIN    : l_in;
	wire [1:0] test_in_cut = bist_active ? BIST_TESTIN : test_in;

    // ------------------------------------------------------------
    // 5) CUT with scan inserted (from circuito08_scan_syn.v)
    // ------------------------------------------------------------
    wire scan_out;

    circuito08 u_cut_scan (
        .clock    (clock),
        .reset    (reset),
        .s        (s_cut),
        .dv       (dv_cut),
        .l_in     (l_in_cut),
        .test_in  (test_in_cut),
        .fz_L     (fz_L),
        .lclk     (lclk),
        .read_a   (read_a),
        .test_out (test_out),
        .scan_en  (scan_en),
        .scan_in  (scan_in),
        .scan_out (scan_out)
    );

    // ------------------------------------------------------------
    // 6) MISR (SHIFT-only enable) compresses scan_out + CUT outputs
    //    data_in[9] is MSB here by concatenation order; keep consistent.
    // ------------------------------------------------------------
    wire [9:0] misr_data_in = {scan_out, fz_L, lclk, read_a, test_out};
    wire [9:0] misr_sig;

    wire misr_en = bist_active & phase_shift;  // SHIFT-only

    misr10 u_misr (
        .clock   (clock),
        .reset   (reset),
        .enable  (misr_en),
        .init    (init),
        .data_in (misr_data_in),
        .sig     (misr_sig)
    );

    // ------------------------------------------------------------
    // 7) Comparator vs GOLDEN signature -> pass_nfail
    // ------------------------------------------------------------
    localparam [9:0] GOLDEN_SIG = 10'h000;  // TODO: replace after golden run

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            pass_nfail <= 1'b0;
        end else if (finish) begin
            pass_nfail <= (misr_sig == GOLDEN_SIG);
        end
    end

endmodule
