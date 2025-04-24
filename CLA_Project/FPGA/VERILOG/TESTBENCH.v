`timescale 1ns / 1ps
`include "CLA_VER.v"
module CLA_with_DFF_tb;

    // Testbench signals
    reg [3:0] A_tb, B_tb;      // 4-bit inputs
    reg Cin_tb;                // Carry-in
    reg Clk_tb;                // Clock signal
    reg Reset_tb;              // Reset signal
    wire [3:0] Sum_out_tb;     // 4-bit sum output
    wire Cout_out_tb;          // Carry-out output

    // Instantiate the CLA_with_DFF module
    CLA_with_DFF uut (
        .A(A_tb),
        .B(B_tb),
        .Cin(Cin_tb),
        .Clk(Clk_tb),
        .Reset(Reset_tb),
        .Sum_out(Sum_out_tb),
        .Cout_out(Cout_out_tb)
    );

    // Clock generation (50% duty cycle, period = 10ns)
    initial begin
        Clk_tb = 0;
        forever #5 Clk_tb = ~Clk_tb; // Toggle clock every 5ns
    end

    // Test sequence
    initial begin
        // Initialize inputs
        $dumpfile("tb.vcd");
        $dumpvars(0,CLA_with_DFF_tb);
        A_tb = 4'b0000;
        B_tb = 4'b0000;
        Cin_tb = 0;
        Reset_tb = 1;

        // Apply Reset
        #10 Reset_tb = 0; A_tb=4'b1001; B_tb=1101; // Deactivate reset after 10ns
        #10 A_tb=4'b0101; B_tb=4'b1010;
        #10 A_tb=4'b1101; B_tb=4'b1011;
        #20;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor($time, " A = %b, B = %b, Cin = %b, Sum = %b, Cout = %b",
                 A_tb, B_tb, Cin_tb, Sum_out_tb, Cout_out_tb);
    end

endmodule