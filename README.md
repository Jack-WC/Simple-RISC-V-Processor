## A 5-stage pipeline RISC-V Processor
+ Support most of RV32I ISA

already implemented instructions
+ R-Type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
+ I-Type:
  + ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
  + LW
  + JALR
+ S-Type: SW
+ B-Type: BEQ, BNE, BLT, BGE, BLTU, BGEU
+ J-Type: JAL
+ U-Type: LUI, AUIPC

Methods:
+ Modular design: 5 stages IF, ID, EX, M, WB and 4 pipeline registers
+ Static branch predictor: BTFNT
+ JAL and BXX target pc is calculated in ID stage and therefore has a 1 cycle penalty
+ BXX misprediction and JALR has a 2 cycle penalty because br_taken or target address cannot be obtained before EX stage
+ Load-use hazard in M stage will stall the pipeline for 1 cycle unless the load data is used in store instruction (need rd in M stage instead of EX)


How to simulate the processor:
1. make sure you have installed iverilog
2. run the following commands
```
iverilog -o tb test_cpu.v
vvp -n tb
```
3. you can use gtkwave to display the waveform `gtkwave top_tb.vcd`
4. some simple testbenches are in the `./test` directory


Future TODO:
+ Branch target buffer (can predict the target pc in IF stage which reduce penalty of JAL, JALR and BXX pred)
+ Dynamic branch predictor (reduce branch mispred penalty)
+ support other extensions of RISC-V (RV64I)
+ make it multi-issue and out of order
+ add cache hierarchy and memory



