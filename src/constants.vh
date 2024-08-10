`ifndef CONSTANTS_H
`define CONSTANTS_H

// R-type Instructions
`define ADD      7'b0110011 // Add instruction, R-type instruction
`define SUB      7'b0110011 // Subtract instruction, R-type instruction
`define SLL      7'b0110011 // Shift Left Logical instruction, R-type instruction
`define SLT      7'b0110011 // Set Less Than instruction, R-type instruction
`define SLTU     7'b0110011 // Set Less Than Unsigned instruction, R-type instruction
`define XOR      7'b0110011 // XOR instruction, R-type instruction
`define SRL      7'b0110011 // Shift Right Logical instruction, R-type instruction
`define SRA      7'b0110011 // Shift Right Arithmetic instruction, R-type instruction
`define AND      7'b0110011 // AND instruction, R-type instruction
`define OR       7'b0110011 // OR instruction, R-type instruction

// I-type Instructions
`define ADDI     7'b0010011 // Add Immediate instruction, I-type instruction
`define SLTI     7'b0010011 // Set Less Than Immediate instruction, I-type instruction
`define SLTIU    7'b0010011 // Set Less Than Immediate Unsigned instruction, I-type instruction
`define XORI     7'b0010011 // XOR Immediate instruction, I-type instruction
`define ORI      7'b0010011 // OR Immediate instruction, I-type instruction
`define ANDI     7'b0010011 // AND Immediate instruction, I-type instruction
`define SLLI     7'b0010011 // Shift Left Logical Immediate instruction, I-type instruction
`define SRLI     7'b0010011 // Shift Right Logical Immediate instruction, I-type instruction
`define LD       7'b0000011 // Load Word instruction, I-type instruction
`define SRAI     7'b0000011 // Shift Right Arithmetic Immediate instruction, I-type instruction


// S-type Instructions
`define SD       7'b0100011 // Store Doubleword instruction, S-type instruction

// B-type Instructions
`define BEQ      7'b1100011 // Branch Equal instruction, B-type instruction
`define BNE      7'b1100011 // Branch Not Equal instruction, B-type instruction
`define BLT      7'b1100011 // Branch Less Than instruction, B-type instruction
`define BGE      7'b1100011 // Branch Greater Than Equal instruction, B-type instruction
`define BLTU     7'b1100011 // Branch Less Than Unsigned instruction, B-type instruction
`define BGEU     7'b1100011 // Branch Greater Than Equal Unsigned instruction, B-type instruction

// U-type Instructions
`define LUI      7'b0110111 // Load Upper Immediate instruction, U-type instruction
`define AUIPC    7'b0010111 // Add Upper Immediate to PC instruction, U-type instruction

// J-type Instructions
`define JAL      7'b1101111 // Jump and Link instruction, J-type instruction

// Additional Instructions and their types
`define JALR     7'b1100111 // Jump and Link Register instruction, I-type instruction
`define LB       7'b0000011 // Load Byte instruction, I-type instruction
`define LH       7'b0000011 // Load Half instruction, I-type instruction
`define LW       7'b0000011 // Load Word instruction, I-type instruction
`define LBU      7'b0000011 // Load Byte Unsigned instruction, I-type instruction
`define LHU      7'b0000011 // Load Half Unsigned instruction, I-type instruction
`define LWU      7'b0000011 // Load Word Unsigned instruction, I-type instruction
`define ADDIW    7'b0011011 // Add Immediate Word instruction, I-type instruction
`define SLLIW    7'b0011011 // Shift Left Logical Immediate Word instruction, I-type instruction
`define SRLIW    7'b0011011 // Shift Right Logical Immediate Word instruction, I-type instruction
`define SRAIW    7'b0011011 // Shift Right Arithmetic Immediate Word instruction, I-type instruction

`define SB       7'b0100011 // Store Byte instruction, S-type instruction
`define SH       7'b0100011 // Store Half instruction, S-type instruction
`define SW       7'b0100011 // Store Word instruction, S-type instruction

`define ADDW     7'b0111011 // Add Word instruction, R-type instruction
`define SUBW     7'b0111011 // Subtract Word instruction, R-type instruction
`define SLLW     7'b0111011 // Shift Left Logical Word instruction, R-type instruction
`define SRLW     7'b0111011 // Shift Right Logical Word instruction, R-type instruction
`define SRAW     7'b0111011 // Shift Right Arithmetic Word instruction, R-type instruction

//instr types
`define R    3'b000 // R-type
`define I   3'b001
`define S   3'b010
`define B   3'b011 // B-type
`define U   3'b100 // U-type
`define J    3'b101 // J-type
`define O    3'b110

//br functs
`define BEQ_FUNCT  3'b000
`define BNE_FUNCT  3'b001
`define BLT_FUNCT  3'b100
`define BGE_FUNCT  3'b101
`define BLTU_FUNCT  3'b110
`define BGEU_FUNCT  3'b111

//lw funct
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

//sw funct
`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

`endif