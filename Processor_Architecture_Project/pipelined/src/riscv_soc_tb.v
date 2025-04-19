`timescale 1ps/1ps
// `include "riscv.v"
// `include "inst_mem.v"
// `include "data_mem.v"

module riscv_soc_tb();

  reg     clk;
  reg     rst;
  
  // Clock generation
  initial begin
    clk = 1'b0;
    forever #50 clk = ~clk;
  end
      
  // Reset generation
  initial begin
    rst = 1'b1;
    #300 rst = 1'b0;
    #100000 $display("---     result is %d         ---\n", verify); 
    #1000 $stop;   
  end
       
  // Signals for instruction memory interface
  wire [31:0] inst_addr;
  wire [31:0] inst;
  wire        inst_ce;

  // Signals for data memory interface
  wire        data_ce;
  wire        data_we;
  wire [31:0] data_addr;
  wire [31:0] wdata;
  wire [31:0] rdata; 
  wire [31:0] verify; 

  // Signal for WriteData_o from EX stage
  wire [31:0] ex_WriteData_o;

  // Instantiate the RISC-V core
  riscv riscv0(
    .clk(clk),
    .rst(rst),
	
    // Instruction memory interface
    .inst_addr_o(inst_addr),
    .inst_i(inst),
    .inst_ce_o(inst_ce),

    // Data memory interface
    .data_ce_o(data_ce),	
    .data_we_o(data_we),
    .data_addr_o(data_addr),
    .data_i(rdata),
    .data_o(wdata),

    // Connect WriteData_o from EX stage
    .ex_WriteData_o(ex_WriteData_o)  // Corrected connection
  );
	
  // Instantiate the instruction memory
  inst_mem inst_mem0(
    .ce(inst_ce),
    .addr(inst_addr),
    .inst(inst)	
  );

  // Instantiate the data memory
  data_mem data_mem0(
    .clk(clk),
    .ce(data_ce),
    .we(data_we),
    .addr(data_addr),
    .data_i(wdata),
    .data_o(rdata),
    .verify(verify)
  );

endmodule