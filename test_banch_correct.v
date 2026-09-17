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

// Instantiate the module under test
online_multiplier #(.n(n)) uut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .y(y),
    .p(p)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test stimulus based on exact trace table
initial begin
    
    // Time=0: Initialize
    reset = 0;
    x = 2'b00;
    y = 2'b00;
    
    // Wait until Time=5000
    #5000;
    
    // Time=10000: Assert reset
    #5000;
    reset = 1;
    
    // Time=15000 (just wait, no input change)
    #5000;
    
    // Time=20000: Apply x=00, y=01
    #5000;
    x = 2'b00;
    y = 2'b01;
    
    // Time=30000: Apply x=01, y=00
    #10000;
    x = 2'b01;
    y = 2'b00;
    
    // Time=40000: Apply x=01, y=01
    #10000;
    x = 2'b01;
    y = 2'b01;
    
    // Time=50000: Apply x=00, y=00
    #10000;
    x = 2'b00;
    y = 2'b00;
    
    // Time=115000: Wait for output (x=00, y=00 continues)
    #65000;
    
    // Time=180000: Apply x=11, y=00
    #65000;
    x = 2'b11;
    y = 2'b00;
    
    // Time=190000: Apply x=01, y=01
    #10000;
    x = 2'b01;
    y = 2'b01;
    
    // Time=210000: Apply x=00, y=00
    #20000;
    x = 2'b00;
    y = 2'b00;
    
    // Time=275000: Wait for output change (no input change)
    #65000;
    
    // Time=340000: Finish simulation
    #65000;
    $finish;
    
end

// Monitor output
initial begin
    $monitor("Time=%0t | reset=%b | x=%b | y=%b | p=%b", 
             $time, reset, x, y, p);
end

// Optional: Add assertions to verify expected outputs
initial begin
    // Wait for reset to be asserted
    wait(reset == 1);
    @(posedge clk);
    
    // Expected outputs at key times
    // Uncomment these to verify:
    /*
    #115000;  
    if (p != 2'b01) $display("ERROR at 115000ns: p=%b (expected 01)", p);
    
    #65000;   // Now at 180000
    if (p != 2'b01) $display("ERROR at 180000ns: p=%b (expected 01)", p);
    
    #95000;   // Now at 275000
    if (p != 2'b11) $display("ERROR at 275000ns: p=%b (expected 11)", p);
    */
end

endmodule