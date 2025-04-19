module EX(
    input  wire         rst,
    input  wire [4:0]   ALUop_i,
    input  wire [31:0]  Oprend1,
    input  wire [31:0]  Oprend2,
    input  wire [4:0]   WriteDataNum_i,
    input  wire         WriteReg_i,
    input  wire [4:0]   RS1,
    input  wire [4:0]   RS2,
    input  wire [4:0]   EX_MEM_RD,
    input  wire [4:0]   MEM_WB_RD,
    input  wire         EX_MEM_RegWrite,
    input  wire         MEM_WB_RegWrite,
    input  wire [31:0]  EX_MEM_ALUResult,
    input  wire [31:0]  MEM_WB_Data,
    input  wire [31:0]  inst_i,          // Add inst_i to the port list
    output reg  [31:0]  ALUResult,
    output reg  [4:0]   WriteDataNum_o,
    output reg          WriteReg_o,
    output reg  [31:0]  WriteData_o      // Add WriteData_o to the port list
);

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    reg [31:0] ForwardedOprend1;
    reg [31:0] ForwardedOprend2;

    // Instantiate the Forwarding Unit
    ForwardingUnit FU(
        .ID_EX_RS1(RS1),
        .ID_EX_RS2(RS2),
        .EX_MEM_RD(EX_MEM_RD),
        .MEM_WB_RD(MEM_WB_RD),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // Forwarding Mux for Oprend1
    always @(*) begin
        case (ForwardA)
            2'b10: ForwardedOprend1 = EX_MEM_ALUResult;
            2'b01: ForwardedOprend1 = MEM_WB_Data;
            default: ForwardedOprend1 = Oprend1;
        endcase
    end

    // Forwarding Mux for Oprend2
    always @(*) begin
        case (ForwardB)
            2'b10: ForwardedOprend2 = EX_MEM_ALUResult;
            2'b01: ForwardedOprend2 = MEM_WB_Data;
            default: ForwardedOprend2 = Oprend2;
        endcase
    end

    // Wires for the results of each ALU operation
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] xor_result;
    wire [31:0] or_result;
    wire [31:0] and_result;
    wire        dummy_cout; // Unused carry outputs

    // Instantiate the ALU submodules
    ADD_32 u_add (
        .A(ForwardedOprend1),
        .B(ForwardedOprend2),
        .Sum(add_result),
        .Cout(dummy_cout)
    );

    SUB_32 u_sub (
        .A(ForwardedOprend1),
        .B(ForwardedOprend2),
        .Diff(sub_result),
        .Cout(dummy_cout)
    );

    SLL_32 u_sll (
        .in(ForwardedOprend1),
        .shamt(ForwardedOprend2[4:0]),
        .out(sll_result)
    );

    SRL_32 u_srl (
        .in(ForwardedOprend1),
        .shamt(ForwardedOprend2[4:0]),
        .out(srl_result)
    );

    XOR_32 u_xor (
        .A(ForwardedOprend1),
        .B(ForwardedOprend2),
        .Y(xor_result)
    );

    OR_32 u_or (
        .A(ForwardedOprend1),
        .B(ForwardedOprend2),
        .Y(or_result)
    );

    AND_32 u_and (
        .A(ForwardedOprend1),
        .B(ForwardedOprend2),
        .Y(and_result)
    );

    // Generate ALUResult and WriteData_o based on ALUop_i
    always @(*) begin
        if (rst) begin
            ALUResult = 32'b0;
            WriteDataNum_o = 5'b0;
            WriteReg_o = 1'b0;
            WriteData_o = 32'b0;
        end else begin
            case (ALUop_i)
                5'b10000: WriteData_o = Oprend1 + Oprend2; // JAL (example)
                5'b10001: WriteData_o = Oprend1 + Oprend2; // BEQ (example)
                5'b10010: WriteData_o = Oprend1 + Oprend2; // BLT (example)
                5'b10100: WriteData_o = Oprend1 + Oprend2; // LW (example)
                5'b10101: WriteData_o = Oprend1 + Oprend2; // SW (example)
                5'b01100: WriteData_o = add_result;       // ADDI
                5'b01101: WriteData_o = add_result;       // ADD
                5'b01110: WriteData_o = sub_result;       // SUB
                5'b01000: WriteData_o = sll_result;       // SLL
                5'b00110: WriteData_o = xor_result;       // XOR
                5'b01001: WriteData_o = srl_result;       // SRL
                5'b00101: WriteData_o = or_result;        // OR
                5'b00100: WriteData_o = and_result;       // AND
                default:  WriteData_o = 32'b0;            // NOP or invalid op
            endcase

            // Assign ALUResult based on the operation
            ALUResult = WriteData_o;
            WriteDataNum_o = WriteDataNum_i;
            WriteReg_o = WriteReg_i;
        end
    end

endmodule



module FULL_ADDER (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    xor(sum, a, b, cin);
    wire w1, w2, w3;
    and(w1, a, b);
    and(w2, a, cin);
    and(w3, b, cin);
    or(cout, w1, w2, w3);
endmodule

module ADD_32 (
    input [31:0] A,
    input [31:0] B,
    output [31:0] Sum,
    output Cout
);
    wire [32:0] Carry;
    assign Carry[0] = 1'b0;
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : adder_loop
            FULL_ADDER fa (
                .a(A[i]),
                .b(B[i]),
                .cin(Carry[i]),
                .sum(Sum[i]),
                .cout(Carry[i+1])
            );
        end
    endgenerate
    assign Cout = Carry[32];
endmodule

module SUB_32 (
    input [31:0] A,
    input [31:0] B,
    output [31:0] Diff,
    output Cout
);
    wire [31:0] B_comp = ~B;
    wire [31:0] B_twos_comp;
    wire Cout_temp;

    ADD_32 add1 (
        .A(B_comp),
        .B(32'd1),
        .Sum(B_twos_comp),
        .Cout(Cout_temp)
    );

    ADD_32 add2 (
        .A(A),
        .B(B_twos_comp),
        .Sum(Diff),
        .Cout(Cout)
    );
endmodule

module AND_32 (
    input [31:0] A,
    input [31:0] B,
    output [31:0] Y
);
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : and_loop
            and u_and(Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module OR_32 (
    input [31:0] A,
    input [31:0] B,
    output [31:0] Y
);
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : or_loop
            or u_or(Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module XOR_32 (
    input [31:0] A,
    input [31:0] B,
    output [31:0] Y
);
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : xor_loop
            xor u_xor(Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module SLL_32 (
    input  [31:0] in,
    input  [4:0]  shamt,
    output [31:0] out
);
    wire [31:0] stage0, stage1, stage2, stage3, stage4;
    assign stage0 = shamt[0] ? {in[30:0], 1'b0}     : in;
    assign stage1 = shamt[1] ? {stage0[29:0], 2'b0}   : stage0;
    assign stage2 = shamt[2] ? {stage1[27:0], 4'b0}     : stage1;
    assign stage3 = shamt[3] ? {stage2[23:0], 8'b0}     : stage2;
    assign stage4 = shamt[4] ? {stage3[15:0], 16'b0}     : stage3;
    assign out = stage4;
endmodule

module SRL_32 (
    input  [31:0] in,
    input  [4:0]  shamt,
    output [31:0] out
);
    wire [31:0] stage0, stage1, stage2, stage3, stage4;
    assign stage0 = shamt[0] ? {1'b0, in[31:1]}       : in;
    assign stage1 = shamt[1] ? {2'b0, stage0[31:2]}     : stage0;
    assign stage2 = shamt[2] ? {4'b0, stage1[31:4]}       : stage1;
    assign stage3 = shamt[3] ? {8'b0, stage2[31:8]}       : stage2;
    assign stage4 = shamt[4] ? {16'b0, stage3[31:16]}     : stage3;
    assign out = stage4;
endmodule

module SRA_32 (
    input  [31:0] in,
    input  [4:0]  shamt,
    output [31:0] out
);
    wire sign;
    assign sign = in[31];
    wire [31:0] stage0, stage1, stage2, stage3, stage4;
    assign stage0 = shamt[0] ? {sign, in[31:1]}       : in;
    assign stage1 = shamt[1] ? {{2{sign}}, stage0[31:2]} : stage0;
    assign stage2 = shamt[2] ? {{4{sign}}, stage1[31:4]} : stage1;
    assign stage3 = shamt[3] ? {{8{sign}}, stage2[31:8]} : stage2;
    assign stage4 = shamt[4] ? {{16{sign}}, stage3[31:16]}: stage3;
    assign out = stage4;
endmodule