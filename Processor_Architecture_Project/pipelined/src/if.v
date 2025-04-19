module PC(

	input	wire 		clk,
	input	wire		rst,
	input 	wire		Branch,
	input 	wire[31:0] 	Addr,
	input	wire[5:0]	stall,
	input	wire		PreBranch,  // predict
	input	wire[31:0]	PreAddr,
	output 	reg 	 	ce,
	output	reg [31:0] 	PC

);

/*
 * This always part controls the signal ce.
 */
always @ (posedge clk) begin
	if (rst)
		ce <= 1'b0;
	else
		ce <= 1'b1;
end

/*
 * This always part controls the signal PC.
 */
always @ (posedge clk) begin
	if (!ce)
		PC <= 32'b0;
	else if (!(stall[0])) begin
		if (Branch)
			PC <= Addr;
		else if (PreBranch)
			PC <= PreAddr;
		else
			PC <= PC + 4'h4;  // New PC equals ((old PC) + 4) per cycle.
	end
end

endmodule