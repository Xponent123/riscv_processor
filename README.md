# Processor Architecture Project

This repository contains the implementation and simulation of a processor architecture that supports both sequential execution and pipelined execution. The project includes a detailed design of essential processor components, a subset of fundamental instructions, and techniques to handle pipeline hazards.

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Key Components](#key-components)
  - [Sequential Implementation](#sequential-implementation)
  - [Pipelined Implementation](#pipelined-implementation)
- [Instruction Set](#instruction-set)
- [Pipeline Hazards & Mitigation](#pipeline-hazards--mitigation)
- [Simulations](#simulations)
- [Team Contributions](#team-contributions)
- [Acknowledgements](#acknowledgements)

## Overview

This project is part of the *Intro to Processor Architecture* course project by Team-4. It focuses on two key approaches:
1. **Sequential Implementation:** Where each instruction executes completely before the next one starts.
2. **Pipelined Implementation:** Where multiple instructions are overlapped in execution through a 5-stage pipeline (IF, ID, EX, MEM, WB) to improve performance.

The report includes a discussion on core components, instruction flows, and the solutions to issues such as instruction dependencies, structural hazards, and control hazards.

## Key Components

### Sequential Implementation

The sequential design comprises the following components:

- **Program Counter (PC):**  
  Tracks the current instruction address and updates it for sequential or branch execution.

- **Instruction Memory:**  
  Stores the machine code and delivers instructions based on the PC address.

- **Register File:**  
  A set of 32 registers (x0 to x31) for fast data access during instruction execution.

- **Control Unit:**  
  Decodes instructions and generates control signals to manage data flow across the processor.

- **ALU Control & ALU:**  
  Determines and executes arithmetic and logical operations (e.g., addition, subtraction, bitwise operations).

- **Immediate Generator:**  
  Extracts and sign-extends immediate values from instructions.

- **Data Memory:**  
  Provides memory access for load (LD) and store (SD) instructions.

### Pipelined Implementation

The pipelined design splits instruction execution into five stages to enhance throughput:

1. **Instruction Fetch (IF):**  
   Retrieves the next instruction from memory.

2. **Instruction Decode (ID):**  
   Decodes the instruction, reads registers, and generates control signals.

3. **Execute (EX):**  
   Performs arithmetic/logical operations and computes addresses.

4. **Memory Access (MEM):**  
   Handles data transfers for load and store instructions.

5. **Write Back (WB):**  
   Writes the result from the ALU or memory back to the register file.

This overlapped processing reduces the clock cycle limitations inherent in the sequential design, thereby improving overall performance.

## Instruction Set

The processor supports a subset of instructions:
- **ADD (Addition):** R-Type instruction for register-to-register addition.
- **SUB (Subtraction):** R-Type instruction for register-to-register subtraction.
- **AND (Bitwise AND):** R-Type instruction performing bitwise logical AND.
- **OR (Bitwise OR):** R-Type instruction performing bitwise logical OR.
- **LD (Load):** I-Type instruction that loads a word from memory into a register.
- **SD (Store):** S-Type instruction that stores a word from a register into memory.
- **BEQ (Branch if Equal):** B-Type instruction that performs conditional branching based on register equality.

## Pipeline Hazards & Mitigation

Pipeline hazards can interrupt smooth instruction execution. This design addresses:
- **Structural Hazards:**  
  Managed by partitioning hardware resources or duplicating memory systems (e.g., Harvard Architecture).

- **Data Hazards:**  
  Resolved using techniques like data forwarding and controlled pipeline stalls (bubbles).

- **Control Hazards:**  
  Mitigated by employing branch prediction strategies and possibly delayed branching.

## Simulations

The project includes extensive simulations to validate both sequential and pipelined processor performance. Test benches simulate various scenarios, demonstrating how pipelining improves throughput and reduces execution delays compared to the sequential approach.


