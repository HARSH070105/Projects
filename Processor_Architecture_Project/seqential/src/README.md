# RISC-V Processor

This project implements a RISC-V processor in Verilog. The design is partitioned into multiple modules, each handling a different stage or function of the processor. The key modules are:

- **if.v**: Instruction Fetch
- **id.v**: Instruction Decode
- **ex.v**: Execute
- **mem.v**: Memory Access
- **wb.v**: Write Back
- **register.v**: Register File
- **inst_mem.v**: Instruction Memory (initialized with machine code)
- **data_mem.v**: Data Memory (initialized with data)

The top-level module is defined in **riscv.v**, which instantiates and connects all the submodules.

## Project Files

- **riscv.v** – Top-level module that integrates the entire processor.
- **if.v, id.v, ex.v, mem.v, wb.v** – Pipeline stage modules.
- **register.v** – Register file.
- **inst_mem.v** – Instruction memory module.
- **data_mem.v** – Data memory module.
- **machinecode.txt** – Contains the 32-bit binary machine code instructions used to initialize the instruction memory.
- **data_mem.txt** – Contains the initial contents (in hexadecimal) for the data memory.
- **tb_riscv.v** – Testbench file to simulate and test the processor.

## Memory Initialization

- **machinecode.txt**: Each line is a 32-bit binary string corresponding to an instruction. The instruction memory module (inst_mem.v) uses an initial block with `$readmemh` or `$readmemb` (depending on your implementation) to load these instructions.
- **data_mem.txt**: Each line contains a 32-bit data word (in hex) that is loaded into the data memory module (data_mem.v).

# Instruction Decoder Overview

## Overview  
This project implements an instruction decoder for a RISC-V processor. The decoder determines control signals for various instruction types such as arithmetic, load/store, and branching operations.  

## Features  
- Supports RISC-V instructions including `addi`, `add`, `sub`, `lw`, `sw`, `beq`, `blt`, `jal`, `sll`, `xor`, `srl`, `or`, and `and`.  
- Generates control signals: `RegRead1`, `RegRead2`, `inst_valid`, `WriteReg`, and `ALUop`.  
- Decodes instruction formats including R-type, I-type, S-type, B-type, and J-type.  

## File Structure  
- `inst_mem.v` – Instruction memory module  
- `data_mem.v` – Data memory module  
- `register.v` – Register file module  
- `ex.v` – Execution unit  
- `id.v` – Instruction decode unit  
- `if.v` – Instruction fetch unit  
- `mem.v` – Memory access unit  
- `riscv.v` – Top-level module integrating all units  
- `wb.v` – Write-back stage  

## Instruction Encoding  
Each instruction is 32 bits, and the decoder extracts relevant fields to determine control signals.  

### **Control Signals**  
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
|-------------|----------|----------|------------|----------|--------|

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
|-------------|-----------------------------------|

## How to run -

Convert the codes into the codes, load them on the machinecode.txt file and the run the commands -
```
iverilog -o riscv_sim riscv_soc_tb.v riscv.v data_mem.v id.v if.v inst_mem.v mem.v register.v wb.v
vvp riscv_sim
```
and the outputs will be on the terminal


## Authors 
**Anshitha**
**Guru** 
**Harsh**  
March 2025, As a part of IPA project