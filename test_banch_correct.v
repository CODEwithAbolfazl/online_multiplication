`timescale 1ns / 1ps

module online_multiplier_tb;

    // Parameters
    parameter n = 8;
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk;
    reg reset;
    reg [1:0] x;
    reg [1:0] y;
    wire [1:0] p;

    // Signed-Digit (SD) Encoding Definitions
    localparam SD_ZERO = 2'b00; //  0
    localparam SD_POS1 = 2'b01; // +1
    localparam SD_NEG1 = 2'b11; // -1

    // Instantiate Module Under Test
    online_multiplier #(.n(n)) uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .p(p)
    );

    // Clock Generation (10ns Period)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Stimulus sequence matching the Radix-2 Trace Table
    initial begin
        // Step 1: Assert active-high reset
        reset = 1;
        x = SD_ZERO;
        y = SD_ZERO;

        // Hold reset for 2 clock cycles then release
        repeat (2) @(negedge clk);
        reset = 0;

        $display("-------------------------------------------------------");
        $display("   j   |  x[j+4]  |  y[j+4]  | Output p[j+1] | Expected");
        $display("-------------------------------------------------------");

        // Feed digit stream line-by-line according to trace table
        apply_step(SD_POS1, SD_POS1, -3, " 0"); // j = -3
        apply_step(SD_POS1, SD_ZERO, -2, " 0"); // j = -2
        apply_step(SD_ZERO, SD_POS1, -1, " 0"); // j = -1
        apply_step(SD_NEG1, SD_NEG1,  0, "+1"); // j =  0
        apply_step(SD_POS1, SD_NEG1,  1, " 0"); // j =  1
        apply_step(SD_ZERO, SD_POS1,  2, "-1"); // j =  2
        apply_step(SD_NEG1, SD_POS1,  3, " 0"); // j =  3
        apply_step(SD_POS1, SD_ZERO,  4, "+1"); // j =  4
        apply_step(SD_ZERO, SD_ZERO,  5, "-1"); // j =  5
        apply_step(SD_ZERO, SD_ZERO,  6, "+1"); // j =  6
        apply_step(SD_ZERO, SD_ZERO,  7, " 0"); // j =  7

        repeat (2) @(negedge clk);
        $display("-------------------------------------------------------");
        $finish;
    end

    // Helper task to apply inputs on falling edge and sample on rising edge
    task apply_step(
        input [1:0] in_x,
        input [1:0] in_y,
        input integer step_j,
        input string expected_p
    );
        begin
            @(negedge clk);
            x = in_x;
            y = in_y;
            @(posedge clk);
            #1; // Brief delay to allow combinational settling before display
            $display("  %2d   |    %s    |    %s    |      %s       |    %s",
                     step_j, format_sd(x), format_sd(y), format_sd(p), expected_p);
        end
    endtask

    // String formatter for Signed-Digit output
    function string format_sd(input [1:0] val);
        case (val)
            SD_POS1: format_sd = " +1";
            SD_NEG1: format_sd = " -1";
            default: format_sd = "  0";
        endcase
    endfunction

endmodule