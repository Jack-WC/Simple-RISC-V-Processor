module ALU(
    input [3:0] funct,
    input [31:0] op1,
    input [31:0] op2,
    output zero,
    output reg [31:0] res
);
    `include "ALUOps.vh"

    always @(*) begin
        case(funct)
            `ALU_ADD: begin
                res = op1 + op2;
            end
            `ALU_SUB: begin
                res = op1 - op2;
            end
            `ALU_SLL: begin
                res = op1 << op2;
            end
            `ALU_SLT: begin
                if(op1[31] != op2[31])
                    res = op1[31];
                else begin
                    res = op1[30:0] < op2[30:0];
                end
            end
            `ALU_SLTU: begin
                res = op1 < op2;
            end
            `ALU_XOR: begin
                res = op1 ^ op2;
            end
            `ALU_SRL: begin
                res = op1 >> op2;
            end
            `ALU_SRA: begin
                res = op1 >>> op2;
            end
            `ALU_OR: begin
                res = op1 | op2;
            end
            `ALU_AND: begin
                res = op1 & op2;
            end
            default: res = 0;
        endcase
    end
    assign zero = (res == 0) ? 1 : 0;
endmodule