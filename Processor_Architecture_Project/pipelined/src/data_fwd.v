module ForwardingUnit(
    input wire [4:0] ID_EX_RS1,   
    input wire [4:0] ID_EX_RS2,   
    input wire [4:0] EX_MEM_RD,   
    input wire [4:0] MEM_WB_RD,   
    input wire EX_MEM_RegWrite,   
    input wire MEM_WB_RegWrite,   
    output reg [1:0] ForwardA,    
    output reg [1:0] ForwardB     
);

    // Forwarding logic for RS1 (first source operand)
    always @(*) begin
        // Check if EX/MEM stage will write to a register and if the destination register matches RS1
        if (EX_MEM_RegWrite && (EX_MEM_RD != 0) && (EX_MEM_RD == ID_EX_RS1))
            ForwardA = 2'b10; // Forward data from EX/MEM stage (ALU result)
        
        // If not, check if MEM/WB stage will write to a register and if the destination register matches RS1
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 0) && (MEM_WB_RD == ID_EX_RS1))
            ForwardA = 2'b01; // Forward data from MEM/WB stage (write-back data)
        
        // If neither condition is met, no forwarding is needed
        else
            ForwardA = 2'b00; // No forwarding, use the original value from the register file
    end

    // Forwarding logic for RS2 (second source operand)
    always @(*) begin
        // Check if EX/MEM stage will write to a register and if the destination register matches RS2
        if (EX_MEM_RegWrite && (EX_MEM_RD != 0) && (EX_MEM_RD == ID_EX_RS2))
            ForwardB = 2'b10; // Forward data from EX/MEM stage (ALU result)
        
        // If not, check if MEM/WB stage will write to a register and if the destination register matches RS2
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 0) && (MEM_WB_RD == ID_EX_RS2))
            ForwardB = 2'b01; // Forward data from MEM/WB stage (write-back data)
        
        // If neither condition is met, no forwarding is needed
        else
            ForwardB = 2'b00; // No forwarding, use the original value from the register file
    end

endmodule