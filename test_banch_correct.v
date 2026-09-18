`timescale 1ns / 1ps

module online_multiplier_tb;

    parameter n = 8;
    parameter CLK_PERIOD = 10;
    parameter DELTA = 7;

    reg clk;
    reg reset;
    reg [1:0] x;
    reg [1:0] y;
    wire [1:0] p;

    localparam SD_ZERO = 2'b00;
    localparam SD_POS1 = 2'b01;
    localparam SD_NEG1 = 2'b11;

    online_multiplier #(.n(n)) uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .p(p)
    );

    // Clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Input streams
    reg [1:0] x_stream [0:n+4];
    reg [1:0] y_stream [0:n+4];
    integer j;

    initial begin
        for (j = 0; j < n+n+7; j = j+1) begin
            x_stream[j] = SD_ZERO;
            y_stream[j] = SD_ZERO;
        end
        x_stream[0] = SD_POS1; y_stream[0] = SD_POS1;
        x_stream[1] = SD_POS1; y_stream[1] = SD_ZERO;
        x_stream[2] = SD_ZERO; y_stream[2] = SD_POS1;
        x_stream[3] = SD_NEG1; y_stream[3] = SD_NEG1;
        x_stream[4] = SD_POS1; y_stream[4] = SD_NEG1;
        x_stream[5] = SD_ZERO; y_stream[5] = SD_POS1;
        x_stream[6] = SD_NEG1; y_stream[6] = SD_POS1;
        x_stream[7] = SD_POS1; y_stream[7] = SD_ZERO;
    end

    // Stimulus
    initial begin
        reset = 1;
        x = SD_ZERO;
        y = SD_ZERO;

        repeat(3) @(posedge clk);
        @(negedge clk);
        reset = 0;

        $display("==========================================================");
        $display(" j  | x[j] | y[j] || p output | Expected");
        $display("==========================================================");

        for (j = 0; j < n+4; j = j+1) begin
            @(negedge clk);
            x = x_stream[j];
            y = y_stream[j];
            @(posedge clk);
            #1;

            if (j >= DELTA) begin
                $display("%3d | %s   | %s   ||   %s     | (check)",
                    j - DELTA,
                    format_sd(x_stream[j-DELTA]),
                    format_sd(y_stream[j-DELTA]),
                    format_sd(p));
            end
        end

        // Flush pipeline
        x = SD_ZERO;
        y = SD_ZERO;
        repeat(n+DELTA) begin
            @(negedge clk);
            @(posedge clk);
            #1;
            $display("flush |  0   |  0   ||   %s     |", format_sd(p));
        end

        $display("==========================================================");
        $finish;
    end

    // Use dumpfile instead of $monitor for waveform debugging
    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, online_multiplier_tb);
    end

    function string format_sd(input [1:0] val);
        case (val)
            SD_POS1: format_sd = "+1";
            SD_NEG1: format_sd = "-1";
            default: format_sd = " 0";
        endcase
    endfunction

endmodule