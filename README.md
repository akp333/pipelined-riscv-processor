# 5-Stage Pipelined RISC-V Processor (Verilog RTL)

A 32-bit, 5-stage pipelined RISC-V (RV32I subset) processor written in Verilog, with a dedicated hazard unit for data forwarding, load-use stalling, and control-flow flushing.

> **Work in progress:** The architecture, module structure, and hazard logic are written, compiled in Icarus Verilog but the pipeline is not yet functionally verified.

## Pipeline Overview

```
 IF  ──►  ID  ──►  EX  ──►  MEM  ──►  WB
 PC       Decode    ALU      Data      Write
 Fetch    RegFile   Branch   Memory    Back
          Control   Target
```

| Stage | Responsibilities |
|-------|------------------|
| **IF**  | PC register, PC+4 adder, PC mux (sequential vs. branch/jump target) |
| **ID**  | Control unit, register file read, immediate extension |
| **EX**  | ALU, forwarding muxes, ALU source mux, branch condition + target calculation |
| **MEM** | Data memory access |
| **WB**  | Result mux (ALU result / memory data / PC+4) and register file write |

Pipeline registers (`if_id_reg`, `id_ex_reg`, `ex_mem_reg`, `mem_wb_reg`) separate each stage.

## Hazard Handling

All hazard logic lives in `hazard_unit.v`.

- **Data forwarding** – Two 3-input muxes in the Execute stage select ALU operands from the register file, the Memory stage (`ALUResultM`), or the Writeback stage (`ResultW`). Memory-stage forwarding takes priority over Writeback-stage forwarding, and `x0` is never forwarded.
- **Load-use stalls** – If the instruction in Execute is a load and its destination matches a source register in Decode, the Fetch and Decode stages are stalled for one cycle and a bubble is inserted into Execute.
- **Control hazards** – When a branch is taken or a jump executes, the incorrectly fetched instructions are flushed from the Decode and Execute stages.

## Roadmap

- [ ] Write a self-checking testbench with directed tests for each hazard type (forwarding, load-use, branch flush)
- [ ] Run a small assembly program
- [ ] Add a waveform-based verification writeup
- [ ] Extend the ISA coverage
- [ ] Add branch prediction

## References

- Harris & Harris, *Digital Design and Computer Architecture: RISC-V Edition* (pipelined processor design)
- The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA
