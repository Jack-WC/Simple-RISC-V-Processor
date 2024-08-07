module BranchPredictor(
    input [31:0] imm,
    output br_pred
);
    assign br_pred = imm[31] == 1;
endmodule