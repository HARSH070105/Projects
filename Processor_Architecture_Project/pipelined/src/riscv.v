// `include "if.v"
// `include "if_id.v"
// `include "id.v"
// `include "id_ex.v"
// `include "ex.v"
// `include "ex_mem.v"
// `include "mem.v"
// `include "mem_wb.v"
// `include "register.v"
// `include "bp.v"
// `include "stall.v"

module riscv(
    input  wire         clk,
    input  wire         rst,
    
    // Instruction memory interface
    output wire [31:0]  inst_addr_o,
    input  wire [31:0]  inst_i,
    output wire         inst_ce_o,

    // Data memory interface
    output wire         data_ce_o,
    output wire         data_we_o,
    output wire [31:0]  data_addr_o,
    input  wire [31:0]  data_i,
    output wire [31:0]  data_o,

    // EX stage output
    output wire [31:0]  ex_WriteData_o
);

	wire[31:0]	PC_o;
	wire[31:0] 	id_PC_i;
	wire[31:0] 	id_inst_i;
	
	wire[4:0] 	id_ALUop_o;
	wire[31:0] 	id_Reg1_o;
	wire[31:0] 	id_Reg2_o;
	wire 		id_WriteReg_o;
	wire[4:0] 	id_WriteDataNum_o;
	wire[31:0] 	id_LinkAddr_o;	
	wire[31:0] 	id_inst_o;
	
	wire[4:0] 	ex_ALUop_i;
	wire[31:0] 	ex_Reg1_i;
	wire[31:0] 	ex_Reg2_i;
	wire 		ex_WriteReg_i;
	wire[4:0] 	ex_WriteDataNum_i;
	wire[31:0] 	ex_LinkAddr_i;	
	wire[31:0]	ex_inst_i;
	
	wire		ex_WriteReg_o;
	wire[4:0]	ex_WriteDataNum_o;
	//wire[31:0] 	ex_WriteData_o;
	wire[4:0] 	ex_ALUop_o;
	wire[31:0] 	ex_mem_addr_o;
	wire[31:0] 	ex_Reg1_o;
	wire[31:0]	ex_Reg2_o;	

	wire		mem_WriteReg_i;
	wire[4:0] 	mem_WriteDataNum_i;
	wire[31:0]	mem_WriteData_i;
	wire[4:0] 	mem_ALUop_i;
	wire[31:0]	mem_Addr_i;
	wire[31:0]	mem_Reg1_i;
	wire[31:0]	mem_Reg2_i;	
		
	wire		mem_WriteReg_o;
	wire[4:0] 	mem_WriteDataNum_o;
	wire[31:0]	mem_WriteData_o;
		
	wire		wb_WriteReg_i;
	wire[4:0] 	wb_WriteDataNum_i;
	wire[31:0]	wb_WriteData_i;
	
	wire		Reg1_Read;
	wire		Reg2_Read;
	wire[31:0] 	Reg1_Data;
	wire[31:0] 	Reg2_Data;
	wire[4:0] 	Reg1_Addr;
	wire[4:0] 	Reg2_Addr;
	
	wire 		id_Branch_Flag;
	wire[31:0] 	Branch_Addr;
	wire[5:0] 	stall_o;
	wire 		Stall_Req_Load;	
	wire 		Stall_Req_Store;
	wire 		Stall_Req_Branch;	
	wire 		is_Branch;
    wire 		id_Accept;
    wire 		pre_Flag;
    wire 		id_Sel;
    wire [31:0] id_pc;

    wire 		pre_branch_flag;
    wire [31:0] pre_Branch_Addr;
    wire 		pre_Accept;
    wire 		pre_Sel;
    wire 		if_id_Accept;
    wire 		if_id_Sel;

	wire [4:0] ex_RS1;
	wire [4:0] ex_RS2;

  	assign inst_addr_o = PC_o;

	PC pc(
		.clk(clk),
		.rst(rst),
		.Branch(id_Branch_Flag),
		.Addr(Branch_Addr),
		.stall(stall_o),	
		.PreBranch(pre_branch_flag),
		.PreAddr(pre_Branch_Addr),
		.ce(inst_ce_o),
		.PC(PC_o)
	);

	PC_ID pc_id(
		.clk(clk),
        .rst(rst),
        .stall(stall_o),
        .ifPC(PC_o),
        .ifInst(inst_i),
        .Predict_i(pre_Accept),       
        .Predict_o(if_id_Accept),
		.idPC(id_PC_i),
        .idInst(id_inst_i)
	);
	
	ID id(
		.rst(rst),
		.pc_i(id_PC_i),
		.inst_i(id_inst_i),
		.RegData1(Reg1_Data),
		.RegData2(Reg2_Data),
		.exALUop(ex_ALUop_o),
		.exWriteReg(ex_WriteReg_o),
		.exWriteData(ex_WriteData_o),
		.exWriteNum(ex_WriteDataNum_o),
		.memWriteReg(mem_WriteReg_o),
		.memWriteData(mem_WriteData_o),
		.memWriteNum(mem_WriteDataNum_o),
		.Predict(if_id_Accept),
		.RegRead1(Reg1_Read),
		.RegRead2(Reg2_Read), 	  
		.RegAddr1(Reg1_Addr),
		.RegAddr2(Reg2_Addr), 
		.ALUop(id_ALUop_o),
		.Reg1(id_Reg1_o),
		.Reg2(id_Reg2_o),
		.WriteData(id_WriteDataNum_o),
		.WriteReg(id_WriteReg_o),
		.Branch(id_Branch_Flag),
		.BranchAddr(Branch_Addr),
		.LinkAddr(id_LinkAddr_o),
		.inst_o(id_inst_o),
		.pc_o(id_pc),
		.BranchFlag(is_Branch),
		.Accept(id_Accept),
		.PredictFlag(pre_Flag),
		.StallBranch(Stall_Req_Branch),
		.StallReqLoad(Stall_Req_Load),
		.StallReqStore(Stall_Req_Store)
	);

	Registers registers(
		.clk(clk),
		.rst(rst),
		.we(wb_WriteReg_i),
		.WriteAddr(wb_WriteDataNum_i),
		.WriteData(wb_WriteData_i),
		.ReadReg1(Reg1_Read),
		.ReadReg2(Reg2_Read),
		.ReadAddr1(Reg1_Addr),
		.ReadAddr2(Reg2_Addr),
		.ReadData1(Reg1_Data),
		.ReadData2(Reg2_Data)
	);

	ID_EX id_ex(
    .clk(clk),
    .rst(rst),
    .stall(stall_o),
    .idALUop(id_ALUop_o),
    .idReg1(id_Reg1_o),
    .idReg2(id_Reg2_o),
    .idWriteNum(id_WriteDataNum_o),
    .idWriteReg(id_WriteReg_o),
    .idRS1(Reg1_Addr),  // 5-bit signal
    .idRS2(Reg2_Addr),  // 5-bit signal
    .idInst(id_inst_o),
    .exALUop(ex_ALUop_i),
    .exReg1(ex_Reg1_i),
    .exReg2(ex_Reg2_i),
    .exWriteNum(ex_WriteDataNum_i),
    .exWriteReg(ex_WriteReg_i),
    .exRS1(ex_RS1),     // 5-bit signal
    .exRS2(ex_RS2),     // 5-bit signal
    .exInst(ex_inst_i)
);
	
	EX ex(
    .rst(rst),
    .ALUop_i(ex_ALUop_i),
    .Oprend1(ex_Reg1_i),
    .Oprend2(ex_Reg2_i),
    .WriteDataNum_i(ex_WriteDataNum_i),
    .WriteReg_i(ex_WriteReg_i),
    .RS1(ex_RS1),
    .RS2(ex_RS2),
    .EX_MEM_RD(mem_WriteDataNum_i),
    .MEM_WB_RD(wb_WriteDataNum_i),
    .EX_MEM_RegWrite(mem_WriteReg_i),
    .MEM_WB_RegWrite(wb_WriteReg_i),
    .EX_MEM_ALUResult(mem_WriteData_i),
    .MEM_WB_Data(wb_WriteData_i),
    .inst_i(ex_inst_i),  // Connect inst_i
    .ALUResult(ex_WriteData_o),
    .WriteDataNum_o(ex_WriteDataNum_o),
    .WriteReg_o(ex_WriteReg_o),
    .WriteData_o(ex_WriteData_o)  // Connect WriteData_o
);

	EX_MEM ex_mem(
		.clk(clk),
		.rst(rst),
		.stall(stall_o),
		.exWriteNum(ex_WriteDataNum_o),
		.exWriteReg(ex_WriteReg_o),
		.exWriteData(ex_WriteData_o),
		.exALUop(ex_ALUop_o),
		.exAddr(ex_mem_addr_o),
		.exReg(ex_Reg2_o),
		.memALUop(mem_ALUop_i),
		.memAddr(mem_Addr_i),
		.memReg(mem_Reg2_i),	
		.memWriteNum(mem_WriteDataNum_i),
		.memWriteReg(mem_WriteReg_i),
		.memWriteData(mem_WriteData_i)			       	
	);
	
	MEM mem(
		.rst(rst),
		.WriteReg_i(mem_WriteReg_i),
		.WriteDataAddr_i(mem_WriteDataNum_i),
		.ALUop_i(mem_ALUop_i),
		.WriteData_i(mem_WriteData_i),
		.MemAddr_i(mem_Addr_i),
		.Reg_i(mem_Reg2_i),
		.MemData_i(data_i),
		.MemWE_o(data_we_o),
		.WriteReg_o(mem_WriteReg_o),
		.MemCE_o(data_ce_o),	
		.WriteDataAddr_o(mem_WriteDataNum_o),
		.WriteData_o(mem_WriteData_o),
		.MemAddr_o(data_addr_o),
		.MemData_o(data_o)	
	);

	MEM_WB mem_wb(
		.clk(clk),
		.rst(rst),
		.stall(stall_o),
		.MemWriteNum(mem_WriteDataNum_o),
		.MemWriteReg(mem_WriteReg_o),
		.MemWriteData(mem_WriteData_o),		
		.wbWriteNum(wb_WriteDataNum_i),
		.wbWriteReg(wb_WriteReg_i),
		.wbWriteData(wb_WriteData_i)						       	
	);
	
	STALL stall(
		.rst(rst),
		.StallLoad(Stall_Req_Load),
		.StallStore(Stall_Req_Store),
		.StallBranch(Stall_Req_Branch),
		.stall(stall_o)       	
	);
	
	BRANCH_PRE branch_pre(
		.rst(rst),
		.pc_i(PC_o),
		.inst_i(inst_i),
		.Branch(is_Branch),
		.Accept(id_Accept),
		.Predict(pre_Flag),
		.idSel(id_Sel),
		.idPC(id_pc),
		.PreBranch(pre_branch_flag),
		.PreAddr(pre_Branch_Addr),
		.PreAccept(pre_Accept),
		.PreSel(pre_Sel)
    );

endmodule