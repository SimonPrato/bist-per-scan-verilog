`timescale 1ns/1ps

module tb_check;

    // Inputs
    reg clk = 0;
    reg rst = 0;
    reg [3:0] a = 0;
    reg [3:0] b = 0;

    // Outputs
    wire [3:0] y;

    // Instantiate CUT
    circuito08 UUT (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .y(y)
    );

    // Clock generator (10ns period)
    always #5 clk = ~clk;

    initial begin
        $display("Starting simulation...");

        // Pulse reset
        rst = 1;
        #10;
        rst = 0;

        // Apply some test vectors
        a = 4'd3;  b = 4'd2;  #10;  // y should become 5
        a = 4'd7;  b = 4'd8;  #10;  // y should become 15
        a = 4'd5;  b = 4'd1;  #10;  // y should become 6

        // Print final result
        $display("Final y = %d", y);

        $finish;
    end

endmodule
