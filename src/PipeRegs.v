// ctr: 00-normal 01-stall 10-bubble
module PipeReg
#(
    parameter bw = 32
)
(
    input clk,
    input n_rst,
    input [1:0] ctr,
    input [bw - 1:0] in,
    output [bw - 1:0] out
);
    reg [bw - 1:0] content;
    initial begin
        content = 0;
    end
    always @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            content <= 0;
        end
        else begin
            case(ctr)
                2'b00: content <= in;
                2'b10: content <= 0;
            endcase
        end
    end
    assign out = content;
    // assign out = (next_ctr == 2'b00) ? content : 0;
endmodule


module IF_ID_Reg(
    input clk,
    input n_rst,
    input [1:0] ctr,

    input [31:0] in_instr,
    input [31:0] in_pc,

    output [31:0] out_instr,
    output [31:0] out_pc
);
    PipeReg#(.bw(32)) instr_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_instr), .out(out_instr));
    PipeReg#(.bw(32)) pc_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_pc), .out(out_pc));

endmodule


module ID_EX_Reg(
    input clk,
    input n_rst,
    input [1:0] ctr,

    input [4:0] in_rs1_id,
    input [4:0] in_rs2_id,
    input [4:0] in_rd_id,
    input [31:0] in_rs1_data,
    input [31:0] in_rs2_data,
    input [31:0] in_imm,
    input [31:0] in_pc,
    input [6:0] in_opcode,
    input [31:0] in_br_pc,
    input [31:0] in_link_pc,
    input [2:0] in_instr_type,
    input [3:0] in_funct,
    input in_br_pred,

    output [4:0] out_rs1_id,
    output [4:0] out_rs2_id,
    output [4:0] out_rd_id,
    output [31:0] out_rs1_data,
    output [31:0] out_rs2_data,
    output [31:0] out_imm,
    output [31:0] out_pc,
    output [6:0] out_opcode,
    output [31:0] out_br_pc,
    output [31:0] out_link_pc,
    output [2:0] out_instr_type,
    output [3:0] out_funct,
    output out_br_pred
);
    PipeReg#(.bw(5)) rs1_id_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rs1_id), .out(out_rs1_id));
    PipeReg#(.bw(5)) rs2_id_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rs2_id), .out(out_rs2_id));
    PipeReg#(.bw(5)) rd_id_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rd_id), .out(out_rd_id));

    PipeReg#(.bw(32)) rs1_data_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rs1_data), .out(out_rs1_data));
    PipeReg#(.bw(32)) rs2_data_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rs2_data), .out(out_rs2_data));
    PipeReg#(.bw(32)) imm_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_imm), .out(out_imm));
    PipeReg#(.bw(32)) pc_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_pc), .out(out_pc));

    PipeReg#(.bw(7)) opcode_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_opcode), .out(out_opcode));
    PipeReg#(.bw(32)) br_pc_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_br_pc), .out(out_br_pc));
    PipeReg#(.bw(32)) link_pc_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_link_pc), .out(out_link_pc));
    PipeReg#(.bw(3)) instr_type_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_instr_type), .out(out_instr_type));
    PipeReg#(.bw(4)) funct_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_funct), .out(out_funct));

    PipeReg#(.bw(1)) br_pred_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_br_pred), .out(out_br_pred));
endmodule


module EX_M_Reg(
    input clk,
    input n_rst,
    input [1:0] ctr,

    input [4:0] in_rd_id,
    input [4:0] in_rs2_id,
    input [31:0] in_rs2_data,
    input [31:0] in_pc,
    input [6:0] in_opcode,
    input [31:0] in_alu_res,
    input [2:0] in_instr_type,

    output [4:0] out_rd_id,
    output [4:0] out_rs2_id,
    output [31:0] out_rs2_data,
    output [31:0] out_pc,
    output [6:0] out_opcode,
    output [31:0] out_alu_res,
    output [2:0] out_instr_type
);
    PipeReg#(.bw(5)) rd_id_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rd_id), .out(out_rd_id));
    PipeReg#(.bw(5)) rs2_id_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rs2_id), .out(out_rs2_id));
    PipeReg#(.bw(32)) rs2_data_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rs2_data), .out(out_rs2_data));
    PipeReg#(.bw(32)) pc_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_pc), .out(out_pc));
    PipeReg#(.bw(7)) opcode_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_opcode), .out(out_opcode));
    PipeReg#(.bw(32)) alu_res_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_alu_res), .out(out_alu_res));
    PipeReg#(.bw(3)) instr_type_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_instr_type), .out(out_instr_type));

endmodule


module M_WB_Reg(
    input clk,
    input n_rst,
    input [1:0] ctr,

    input [4:0] in_rd_id,
    input [31:0] in_pc,
    input [6:0] in_opcode,
    input [31:0] in_rd_mem_data,
    input [31:0] in_alu_res,
    input [2:0] in_instr_type,

    output [4:0] out_rd_id,
    output [31:0] out_pc,
    output [6:0] out_opcode,
    output [31:0] out_rd_mem_data,
    output [31:0] out_alu_res,
    output [2:0] out_instr_type
);
    PipeReg#(.bw(5)) rd_id_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rd_id), .out(out_rd_id));
    PipeReg#(.bw(32)) pc_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_pc), .out(out_pc));
    PipeReg#(.bw(7)) opcode_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_opcode), .out(out_opcode));
    PipeReg#(.bw(32)) rd_mem_data_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_rd_mem_data), .out(out_rd_mem_data));
    PipeReg#(.bw(32)) alu_res_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_alu_res), .out(out_alu_res));
    PipeReg#(.bw(3)) instr_type_reg(.clk(clk), .n_rst(n_rst), .ctr(ctr), .in(in_instr_type), .out(out_instr_type));

endmodule