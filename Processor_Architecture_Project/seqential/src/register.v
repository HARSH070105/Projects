 module Registers(
    input   wire        clk,
    input   wire        rst,
    input   wire        we,
    input   wire[4:0]   WriteAddr,
    input   wire[31:0]  WriteData,
    input   wire        ReadReg1,
    input   wire        ReadReg2,
    input   wire[4:0]   ReadAddr1,
    input   wire[4:0]   ReadAddr2,
    
    output  reg [31:0]  ReadData1,
    output  reg [31:0]  ReadData2
);

    integer i;
    reg [31:0] regFile [0:32];
  
always @ (posedge clk) begin
    regFile[5'h0] <= 32'b0;   
    if (rst)
        for (i = 0; i < 32; i = i + 1)
            regFile[i] <= 32'b0;
    if (!rst && we && WriteAddr != 5'h0) begin
        regFile[WriteAddr] <= WriteData;  
        $display("x%d = %h", WriteAddr, WriteData);  
    end
end

always @ (*) begin
    if (rst || ReadAddr1 == 5'h0)
        ReadData1 <= 32'b0;
    else if (ReadReg1) begin
        ReadData1 <= regFile[ReadAddr1];
    end else
        ReadData1 <= 32'b0;
end

always @ (*) begin
    if (rst || ReadAddr2 == 5'h0)
        ReadData2 <= 32'b0;
    else if (ReadReg2) begin
        ReadData2 <= regFile[ReadAddr2];
    end else
        ReadData2 <= 32'b0;
end
    
endmodule