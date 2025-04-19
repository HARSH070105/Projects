/* Notes:

 ***************************************************************************************
 * Inst * ALUSrc * MemToReg * RegWrite * MemRead * MemWrite * Branch * ALUOp1 * ALUOp0 *
 ***************************************************************************************
 *   R  *    0   *     0    *     1    *    0    *     0    *    0   *    1   *    0   *
 ***************************************************************************************
 *  lw  *    1   *     1    *     1    *    1    *     0    *    0   *    0   *    0   *
 ***************************************************************************************
 *  sw  *    1   *     x    *     0    *    0    *     1    *    0   *    0   *    0   *
 ***************************************************************************************
 * beq  *    0   *     x    *     0    *    0    *     0    *    1   *    0   *    1   *
 ***************************************************************************************
 */

module ID(
    input   wire        rst,
    input   wire[31:0]  pc_i,
    input   wire[31:0]  inst_i,
    input   wire[31:0]  RegData1,
    input   wire[31:0]  RegData2,
    
    output  reg         RegRead1,
    output  reg         RegRead2,
    output  reg [4:0]   RegAddr1,
    output  reg [4:0]   RegAddr2,

    output  reg [4:0]   ALUop,
    output  reg [31:0]  Reg1,
    output  reg [31:0]  Reg2,
    output  reg [4:0]   WriteData,
    output  reg         WriteReg,

    output  reg         Branch,
    output  reg [31:0]  BranchAddr,
    output  reg [31:0]  LinkAddr,
    output  wire[31:0]  inst_o
);
    reg inst_valid;
    reg [31:0] imm;

    wire[31:0] pc_add_4;
    wire[31:0] pc_add_imm_B;
    wire[31:0] pc_add_imm_J;
    wire[4:0]  rs1_addr = inst_i[19:15];
    wire[4:0]  rs2_addr = inst_i[24:20];
    wire[4:0]  rd_addr  = inst_i[11:7];

    wire[31:0] imm_I = {{21{inst_i[31:31]}}, inst_i[30:20]};
    wire[31:0] imm_B = {{20{inst_i[31:31]}}, inst_i[ 7: 7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire[31:0] imm_J = {{12{inst_i[31:31]}}, inst_i[19:12], inst_i[20:20], inst_i[30:25], inst_i[24:21], 1'b0};

    assign inst_o = inst_i;
    assign pc_add_4 = pc_i + 4;
    assign pc_add_imm_B = pc_i + imm_B;
    assign pc_add_imm_J = pc_i + imm_J;

always @ (*) begin
    if (rst)
        ALUop <= 5'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: ALUop <= 5'b10000;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: ALUop <= 5'b10001;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: ALUop <= 5'b10010;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: ALUop <= 5'b10100;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: ALUop <= 5'b10101;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: ALUop <= 5'b01100;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: ALUop <= 5'b01101;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: ALUop <= 5'b01110;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: ALUop <= 5'b01000;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: ALUop <= 5'b00110;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: ALUop <= 5'b01001;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: ALUop <= 5'b00101;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: ALUop <= 5'b00100;  // and
            default: ALUop <= 5'b0;
        endcase
    end
end
// 0000000  00101  00000  000  00001  0010011
// 0000000  01010  00000  000  00010  0010011
// 0000000  00010  00001  000  00011  0110011
// 0100000  00001  00011  000  00100  0110011
// 0000000  00010  00001  111  00101  0110011
// 0000000  00010  00001  110  00110  0110011
// 0000000  00010  00001  100  00111  0110011

always @ (*) begin
    if (rst)
        WriteReg <= 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: WriteReg <= 1'b1;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: WriteReg <= 1'b0;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: WriteReg <= 1'b0;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: WriteReg <= 1'b1;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: WriteReg <= 1'b0;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: WriteReg <= 1'b1;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: WriteReg <= 1'b1;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: WriteReg <= 1'b1;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: WriteReg <= 1'b1;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: WriteReg <= 1'b1;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: WriteReg <= 1'b1;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: WriteReg <= 1'b1;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: WriteReg <= 1'b1;  // and
            default: WriteReg <= 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        inst_valid <= 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: inst_valid <= 1'b0;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: inst_valid <= 1'b0;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: inst_valid <= 1'b0;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: inst_valid <= 1'b0;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: inst_valid <= 1'b0;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: inst_valid <= 1'b0;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: inst_valid <= 1'b0;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: inst_valid <= 1'b0;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: inst_valid <= 1'b0;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: inst_valid <= 1'b0;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: inst_valid <= 1'b0;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: inst_valid <= 1'b0;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: inst_valid <= 1'b0;  // and
            default: inst_valid <= 1'b1;
        endcase
    end
end

always @ (*) begin
    if (rst)
        RegRead1 <= 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: RegRead1 <= 1'b0;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: RegRead1 <= 1'b1;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: RegRead1 <= 1'b1;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: RegRead1 <= 1'b1;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: RegRead1 <= 1'b1;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: RegRead1 <= 1'b1;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: RegRead1 <= 1'b1;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: RegRead1 <= 1'b1;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: RegRead1 <= 1'b1;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: RegRead1 <= 1'b1;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: RegRead1 <= 1'b1;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: RegRead1 <= 1'b1;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: RegRead1 <= 1'b1;  // and
            default: RegRead1 <= 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        RegRead2 <= 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: RegRead2 <= 1'b0;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: RegRead2 <= 1'b1;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: RegRead2 <= 1'b1;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: RegRead2 <= 1'b0;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: RegRead2 <= 1'b1;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: RegRead2 <= 1'b0;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: RegRead2 <= 1'b1;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: RegRead2 <= 1'b1;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: RegRead2 <= 1'b1;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: RegRead2 <= 1'b1;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: RegRead2 <= 1'b1;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: RegRead2 <= 1'b1;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: RegRead2 <= 1'b1;  // and
            default: RegRead2 <= 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        imm <= 32'b0;
    else if (inst_i[14:12] == 3'b000 && inst_i[6:0] == 7'b0010011)  // addi
        imm <= imm_I;
    else
        imm <= 32'b0;
end

always @ (*) begin
    if (rst)
        LinkAddr <= 32'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
        LinkAddr <= pc_add_4;
    else
        LinkAddr <= 32'b0;
end

always @ (*) begin
    if (rst)
        BranchAddr <= 32'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
        BranchAddr <= pc_add_imm_J;
    else if (inst_i[6:0] == 7'b1100011 && inst_i[13:12] == 2'b0)  // beq, blt
        BranchAddr <= pc_add_imm_B;
    else
        BranchAddr <= 32'b0;
end

always @ (*) begin
    if (rst)
        Branch <= 1'b0;
    else if (inst_i[6:0] == 7'b1101111 || (inst_i[6:0] == 7'b1100011 && inst_i[13:12] == 2'b0))  // jal, beq, blt
        Branch <= 1'b1;
    else
        Branch <= 1'b0;
end

always @ (*) begin
    if (rst)
        WriteData <= 5'b0;
    else
        WriteData <= rd_addr;
end

always @ (*) begin
    if (rst)
        RegAddr1 <= 5'b0;
    else
        RegAddr1 <= rs1_addr;
end

always @ (*) begin
    if (rst)
        RegAddr2 <= 5'b0;
    else
        RegAddr2 <= rs2_addr;
end

always @ (*) begin
    if (rst)
        Reg1 <= 32'b0;
    else if (RegRead1)
        Reg1 <= RegData1;
    else
        Reg1 <= imm;
end

always @ (*) begin
    if (rst)
        Reg2 <=  32'b0;
    else if (RegRead2)
        Reg2 <= RegData2;
    else
        Reg2 <= imm;
end

endmodule