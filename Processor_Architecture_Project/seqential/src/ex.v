module EX(
    input  wire         rst,
    input  wire [4:0]   ALUop_i,
    input  wire [31:0]  Oprend1,
    input  wire [31:0]  Oprend2,
    input  wire [4:0]   WriteDataNum_i,
    input  wire         WriteReg_i,
    input  wire [31:0]  LinkAddr,
    input  wire [31:0]  inst_i,

    output reg          WriteReg_o,
    output wire [4:0]   ALUop_o,
    output reg  [4:0]   WriteDataNum_o,
    output reg  [31:0]  WriteData_o,
    output wire [31:0]  MemAddr_o,
    output wire [31:0]  Result
);

  assign ALUop_o = ALUop_i;
  assign Result  = Oprend2;
  
  assign MemAddr_o = Oprend1 + ((inst_i[6:0] == 7'b0000011) ? {{20{inst_i[31]}}, inst_i[31:20]} : {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]});

  always @(*) begin
    if (rst)
      WriteDataNum_o = 5'b0;
    else
      WriteDataNum_o = WriteDataNum_i;
  end

  always @(*) begin
    if (rst)
      WriteReg_o = 1'b0;
    else
      WriteReg_o = WriteReg_i;
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

  // Instantiate the ALU submodules outside any always block
  ADD_32 u_add (
      .A(Oprend1),
      .B(Oprend2),
      .Sum(add_result),
      .Cout(dummy_cout)
  );

  SUB_32 u_sub (
      .A(Oprend1),
      .B(Oprend2),
      .Diff(sub_result),
      .Cout(dummy_cout)
  );

  SLL_32 u_sll (
      .in(Oprend1),
      .shamt(Oprend2[4:0]),
      .out(sll_result)
  );

  SRL_32 u_srl (
      .in(Oprend1),
      .shamt(Oprend2[4:0]),
      .out(srl_result)
  );

  XOR_32 u_xor (
      .A(Oprend1),
      .B(Oprend2),
      .Y(xor_result)
  );

  OR_32 u_or (
      .A(Oprend1),
      .B(Oprend2),
      .Y(or_result)
  );

  AND_32 u_and (
      .A(Oprend1),
      .B(Oprend2),
      .Y(and_result)
  );

  // Generate WriteData_o based on ALUop_i
  always @(*) begin
    if (rst)
      WriteData_o = 32'b0;
    else begin
      case (ALUop_i)
        5'b10000: WriteData_o = LinkAddr;       // JAL
        5'b10001: WriteData_o = LinkAddr;       // BEQ
        5'b10010: WriteData_o = LinkAddr;       // BLT
        5'b10100: WriteData_o = 32'b0;            // LW
        5'b10101: WriteData_o = 32'b0;            // SW
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