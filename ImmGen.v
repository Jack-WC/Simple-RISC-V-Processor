module ImmGen(
    input [31:0] instr,
    input [2:0] instr_type,
    output reg [31:0] imm
);
    `include "constants.vh"

    always @(*) begin
        case(instr_type)
            `I: begin
                // slli srli srai
                if(instr[14:12] == 3'b001 || instr[14:12] == 3'b101)
                    imm = {27'b0, instr[24:20]};
                else
                    imm = {{21{instr[31]}}, instr[30:20]};
            end
            `S: begin
                imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
            end
            `B: begin
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            `U: begin
                imm = {instr[31:12], 12'b0};
            end
            `J: begin
                imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end
            default:
                imm = 0;
        endcase
    end
endmodule