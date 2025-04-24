module CLA_with_DFF (
    input [3:0] A, B,         // 4-bit inputs
    input Cin,                // Carry-in
    input Clk,                // Clock signal
    input Reset,              // Reset signal
    output [3:0] Sum_out,     // 4-bit sum output (stored in D flip-flops)
    output Cout_out           // Carry-out (stored in a D flip-flop)
);
    wire [3:0] G, P;          // Generate and Propagate wires
    wire [3:0] C;             // Internal carry wires
    wire [3:0] Sum;           // Sum calculation wires
    wire Cout;                // Final carry-out
    wire [3:0] Sum_reg;       // Registered sum output
    wire Cout_reg;            // Registered carry-out output

    // Generate and Propagate Logic
    assign G = A & B;         // Generate: G[i] = A[i] & B[i]
    assign P = A ^ B;         // Propagate: P[i] = A[i] ^ B[i]

    // Carry Lookahead Logic
    assign C[0] = Cin;                           // First carry bit = Cin
    assign C[1] = G[0] | (P[0] & C[0]);          // C[1] = G[0] + P[0] * C[0]
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);

    // Sum Calculation
    assign Sum = P ^ C;       // Sum[i] = P[i] ^ C[i]

    // D Flip-Flops for Registered Outputs
    DFlipFlop DFF0 (.D(Sum[0]), .Clk(Clk), .Reset(Reset), .Q(Sum_reg[0]));
    DFlipFlop DFF1 (.D(Sum[1]), .Clk(Clk), .Reset(Reset), .Q(Sum_reg[1]));
    DFlipFlop DFF2 (.D(Sum[2]), .Clk(Clk), .Reset(Reset), .Q(Sum_reg[2]));
    DFlipFlop DFF3 (.D(Sum[3]), .Clk(Clk), .Reset(Reset), .Q(Sum_reg[3]));
    DFlipFlop DFFC (.D(Cout),  .Clk(Clk), .Reset(Reset), .Q(Cout_reg));

    // Assign Registered Outputs
    assign Sum_out = Sum_reg;
    assign Cout_out = Cout_reg;
endmodule

// D Flip-Flop Module
module DFlipFlop (
    input D,         // Data input
    input Clk,       // Clock input
    input Reset,     // Synchronous Reset input
    output reg Q     // Data output
);
    always @(posedge Clk) begin
        if (Reset)
            Q <= 0;   // Reset Q to 0
        else
            Q <= D;   // Store D in Q on clock edge
    end
endmodule