// Modified id_ex.v to include RS1 and RS2 forwarding
module ID_EX(
    input   wire        clk,
    input   wire        rst,
    input   wire[5:0]   stall,
    input   wire[4:0]   idALUop,
    input   wire[31:0]  idReg1,
    input   wire[31:0]  idReg2,
    input   wire[4:0]   idWriteNum,
    input   wire        idWriteReg,
    input   wire[4:0]   idRS1,
    input   wire[4:0]   idRS2,
    input   wire[31:0]  idInst,
    output  reg [4:0]   exALUop,
    output  reg [31:0]  exReg1,
    output  reg [31:0]  exReg2,
    output  reg [4:0]   exWriteNum,
    output  reg         exWriteReg,
    output  reg [4:0]   exRS1,
    output  reg [4:0]   exRS2,
    output  reg [31:0]  exInst
);

always @(posedge clk) begin
    if (rst) begin
        exALUop   <= 5'b0;
        exReg1    <= 32'b0;
        exReg2    <= 32'b0;
        exWriteNum <= 5'b0;
        exWriteReg <= 1'b0;
        exRS1     <= 5'b0;
        exRS2     <= 5'b0;
        exInst    <= 32'b0;
    end else if (!stall[2]) begin
        exALUop   <= idALUop;
        exReg1    <= idReg1;
        exReg2    <= idReg2;
        exWriteNum <= idWriteNum;
        exWriteReg <= idWriteReg;
        exRS1     <= idRS1;
        exRS2     <= idRS2;
        exInst    <= idInst;
    end
end
endmodule
