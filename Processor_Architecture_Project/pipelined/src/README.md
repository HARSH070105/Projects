    # RISC-V Pipelined Processor with Data Forwarding

## Overview
This project implements a RISC-V pipelined processor with support for data forwarding to optimize execution by resolving data hazards. The design follows a modular approach, where each stage of the pipeline is implemented as a separate Verilog module.

## Modules Description
Below is a brief description of each module in the project:

### 1. **Instruction Fetch (IF)**
   - File: `if.v`
   - Fetches instructions from instruction memory.
   - Interfaces with `inst_mem.v` to get instruction data.
   - Passes fetched instruction to `if_id.v` pipeline register.

### 2. **Instruction Memory (IMEM)**
   - File: `inst_mem.v`
   - Stores program instructions.
   - Provides instructions to the IF stage when requested.

### 3. **IF/ID Pipeline Register**
   - File: `if_id.v`
   - Holds instruction and PC value to pass to the Decode stage.

### 4. **Instruction Decode (ID)**
   - File: `id.v`
   - Decodes instructions and extracts operands from the register file (`register.v`).
   - Generates control signals for execution.
   - Passes values to the `id_ex.v` pipeline register.

### 5. **Register File**
   - File: `register.v`
   - Contains 32 general-purpose registers.
   - Supports reading and writing registers.
   - Integrated with forwarding to resolve hazards.

### 6. **ID/EX Pipeline Register**
   - File: `id_ex.v`
   - Holds decoded instruction data and control signals.
   - Passes information to the EX stage.

### 7. **Execution (EX)**
   - File: `ex.v`
   - Performs ALU operations based on the instruction type.
   - Implements a **Forwarding Unit** to handle data hazards.
   - Uses multiplexers to select the correct values for execution.
   - Outputs results to the `ex_mem.v` pipeline register.

### 8. **Forwarding Unit**
   - Integrated into `ex.v`.
   - Detects data hazards and selects the correct data source for execution.
   - Forwarding control signals ensure proper execution without stalls.

### 9. **EX/MEM Pipeline Register**
   - File: `ex_mem.v`
   - Holds ALU results and control signals.
   - Passes execution results to the Memory stage.

### 10. **Memory Access (MEM)**
   - File: `mem.v`
   - Handles data memory operations (load/store).
   - Passes data to `mem_wb.v` pipeline register.

### 11. **MEM/WB Pipeline Register**
   - File: `wb.v`
   - Holds data to be written back to the register file.

### 12. **Write-Back (WB)**
   - File: `wb.v`
   - Writes the final result back to the register file.

### 13. **Branch Prediction (BP)**
   - File: `bp.v`
   - Implements branch prediction to minimize pipeline stalls.

### 14. **Stall Control Unit**
   - File: `stall.v`
   - Handles stalls and flushes for pipeline control.

### 15. **Top-Level RISC-V Processor**
   - File: `riscv.v`
   - Integrates all pipeline stages and control units.
   - Instantiates forwarding and hazard detection mechanisms.

## Features Implemented
- **Five-stage pipeline:** IF, ID, EX, MEM, WB.
- **Data Forwarding:** Eliminates stalls by resolving data hazards dynamically.
- **Pipeline Registers:** Ensures smooth data flow across stages.
- **Hazard Detection:** Prevents incorrect execution due to dependencies.
- **Branch Prediction:** Optimizes control flow execution.

## **Control Signals**  
| Instruction | RegRead1 | RegRead2 | inst_valid | WriteReg | ALUop  |
|-------------|----------|----------|------------|----------|--------|
| `jal`       | 0        | 0        | 0          | 1        | `10000`|
| `beq`       | 1        | 1        | 0          | 0        | `10001`|
| `blt`       | 1        | 1        | 0          | 0        | `10010`|
| `lw`        | 1        | 0        | 0          | 1        | `10100`|
| `sw`        | 1        | 1        | 0          | 0        | `10101`|
| `addi`      | 1        | 0        | 0          | 1        | `01100`|
| `add`       | 1        | 1        | 0          | 1        | `01101`|
| `sub`       | 1        | 1        | 0          | 1        | `01110`|
| `sll`       | 1        | 1        | 0          | 1        | `01000`|
| `xor`       | 1        | 1        | 0          | 1        | `00110`|
| `srl`       | 1        | 1        | 0          | 1        | `01001`|
| `or`        | 1        | 1        | 0          | 1        | `00101`|
| `and`       | 1        | 1        | 0          | 1        | `00100`|

## Table fot instructions

| Instruction |               Codes               |
|-------------|-----------------------------------|
| `jal`       | bxxxxxxxxxxxxxxxxxxxxxxxxx1101111 |
| `beq`       | bxxxxxxxxxxxxxxxxx000xxxxx1100011 |
| `blt`       | bxxxxxxxxxxxxxxxxx100xxxxx1100011 |
| `lw`        | bxxxxxxxxxxxxxxxxx010xxxxx0000011 |
| `sw`        | bxxxxxxxxxxxxxxxxx010xxxxx0100011 |
| `addi`      | bxxxxxxxxxxxxxxxxx000xxxxx0010011 |
| `add`       | b0000000xxxxxxxxxx000xxxxx0110011 |
| `sub`       | b0100000xxxxxxxxxx000xxxxx0110011 |
| `sll`       | b0000000xxxxxxxxxx001xxxxx0110011 |
| `xor`       | b0000000xxxxxxxxxx100xxxxx0110011 |
| `srl`       | b0000000xxxxxxxxxx101xxxxx0110011 |
| `or`        | b0000000xxxxxxxxxx110xxxxx0110011 |
| `and`       | b0000000xxxxxxxxxx111xxxxx0110011 |

## How to Run
1. Simulate using Verilog testbenches.
```
iverilog -o risc_sim bp.v data_mem.v ex_mem.v ex.v id_ex.v id.v if_id.v if.v inst_mem.v mem_wb.v mem.v register.v riscv.v stall.v wb.v riscv_soc_tb.v data_fwd.v
vvp risc_sim
```
2. Ensure `Machine_code.txt` and `Data_mem.txt` contain the necessary instruction and data values.
3. Verify output using waveform analysis tools.

## Expected Outputs
- Correct ALU computation results.
- Accurate register updates with forwarded values.
- Minimal pipeline stalls due to optimized hazard handling.

## Future Enhancements
- Implementing advanced branch prediction techniques.
- Supporting more RISC-V instruction types.
- Optimizing forwarding logic for more efficiency.

