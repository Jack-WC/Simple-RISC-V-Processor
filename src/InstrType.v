module InstrType(
    input [6:0] opcode,
    output reg [2:0] instr_type
);
    `include "constants.vh"

    always @(*) begin
        if (opcode == 7'b0110011) begin
            instr_type = `R;
        end
        else if(opcode == 7'b0010011 || opcode == 7'b0000011 || opcode == 7'b1100111) begin
            instr_type = `I;
        end
        else if(opcode == 7'b0100011) begin
            instr_type = `S;
        end
        else if(opcode == 7'b1100011) begin
            instr_type = `B;
        end
        else if(opcode == 7'b0110111 || opcode == 7'b0010111) begin
            instr_type = `U;
        end
        else if(opcode == 7'b1101111) begin
            instr_type = `J;
        end
        else begin
            instr_type = `O;
        end
    end
endmodule