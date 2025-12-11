`timescale 1ns/1ps

module state_machine(clock, reset, bist_start, mode, bist_end, init, running, finish);
input clock, reset, bist_start;
output reg mode, bist_end, init, running, finish;

// Registers containing the current and next state
reg [2:0] state, next_state;

// Parameters identifying states
localparam [2:0] S0=0, S1=1, S2=2, S3=3, S4=4, S5=5;

// Parameters N and M defining the output sequence
parameter N = 7;
parameter M = 10;

// Calculate required register sizes to contain the number of iterations conducted.
parameter N_SIZE = $clog2(N + 1);
parameter M_SIZE = $clog2(M + 1);

// Declaration of registers keeping track of iterations producting hte output sequence.
reg [N_SIZE:0] cnt_n;
reg [M_SIZE:0] cnt_m;

// Register to keep track of the bist_start value one clock cycle ago.
reg prev_bist_start;

// Implement counters for cnt_n and cnt_m
always @(posedge clock) begin
    if (reset == 1) begin
        cnt_n <= 0;
        cnt_m <= 0;
    end
    else if (cnt_n > N - 1) begin
        cnt_n <= 0;
        cnt_m <= cnt_m + 1;
    end
    else if (cnt_m > M) begin
        cnt_m <= 0;
        cnt_n <= 0;
    end
    else if (next_state == S2) begin
        cnt_n <= cnt_n + 1;
    end
    else begin
        cnt_n <= cnt_n;
        cnt_m <= cnt_m;
    end
end

// Process the next state
always @(*)
    begin

    case (state)
    S0: begin
        if (bist_start && !prev_bist_start) next_state = S1;
        else next_state = S0;
        end

    S1: next_state = S2;

    S2: begin 
	if (cnt_n > N-1) next_state = S3;
        else begin
        next_state = S2;
        end
	end

    S3: begin
	if (cnt_m > M) next_state = S4;
        else begin
        next_state = S2;
	end
	end

    S4: next_state = S5;

    S5: begin
	if (bist_start && !prev_bist_start) begin
        next_state = S1;
        end
        else next_state = S5;
	end

    default: begin
        next_state = S0;
    end

endcase
end

// Set the next state to S0 if reset is HIGH
always @(posedge clock)
    begin
    prev_bist_start <= bist_start;
    if (reset == 1'b1)
        state <= S0;
    else
        state <= next_state;
end

// Set output depending on state
  always @(state) begin
    case (state)
        S0: begin
        mode <= 0;
        bist_end <= 0;
        init <= 0;
        running <= 0;
        finish <= 0;
        end

        S1: begin
        mode <= 0;
        bist_end <= 0;
        init <= 1;
        running <= 0;
        finish <= 0;
        end

        S2: begin
        mode <= 1;
        bist_end <= 0;
        init <= 0;
        running <= 1;
        finish <= 0;
        end

        S3: begin
        mode <= 0;
        bist_end <= 0;
        init <= 0;
        running <= 1;
        finish <= 0;
        end

        S4: begin
        mode <= 0;
        bist_end <= 0;
        init <= 0;
        running <= 0;
        finish <= 1;
        end

        S5: begin
        mode <= 0;
        bist_end <= 1;
        init <= 0;
        running <= 0;
        finish <= 0;
        end

        default: begin
        mode <= 0;
        bist_end <= 0;
        init <= 0;
        running <= 0;
        finish <= 0;
        end
    endcase
end

endmodule

