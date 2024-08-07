`include "BranchPredictor.v"

module IF_stage(
    input clk,
    input n_rst,
    input stall,
    input [6:0] id_opcode,
    input [31:0] id_target_pc,
    input [6:0] ex_opcode,
    input [31:0] ex_target_pc,
    input ex_br_taken,
    input ex_br_pred,
    input id_br_pred,
    input [31:0] ex_link_pc,

    output [31:0] instr,
    output [31:0] out_pc
);
    //instr fetch
    // get next_pc
    reg [31:0] next_pc;
    always @(*) begin
        if(stall)
            next_pc = out_pc;
        else if((ex_opcode == `BEQ && ex_br_taken && !ex_br_pred) || ex_opcode == `JALR)
            next_pc = ex_target_pc;
        else if(ex_opcode == `BEQ && !ex_br_taken && ex_br_pred)
            next_pc = ex_link_pc;
        else if(id_opcode == `JAL || (id_opcode == `BEQ && id_br_pred))
            next_pc = id_target_pc;
        else
            next_pc = out_pc + 4;
    end

    PC counter(
        .clk(clk), .n_rst(n_rst),
        .next_pc(next_pc),
        .out_pc(out_pc)
    );
    InstrMem instr_mem(.pc(out_pc[11:2]), .instr(instr));
endmodule


module ID_stage(
    input clk,
    input n_rst,
    input [31:0] instr,
    input [31:0] pc,

    input [31:0] wb_wr_data,
    input [4:0] wb_wr_id,
    input wb_wr_en_reg,

    output [4:0] rs1_id,
    output [4:0] rs2_id,
    output [4:0] out_rd_id,
    output [3:0] funct,
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [31:0] imm,
    output [6:0] opcode,
    output [2:0] instr_type,
    output [31:0] target_pc,
    output [31:0] link_pc,
    output br_pred
);
    //instr decode
    assign opcode = instr[6:0];
    assign rs1_id = instr[19:15];
    assign rs2_id = instr[24:20];
    assign funct = instr[14:12];
    assign out_rd_id = instr[11:7];

    RegFile reg_file(
        .clk(clk), .n_rst(n_rst),
        .rs1_id(rs1_id), .rs2_id(rs2_id),
        .wb_wr_en(wb_wr_en_reg), .wb_wr_id(wb_wr_id), .wb_wr_data(wb_wr_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );
    InstrType inst_ty(
        .opcode(opcode),

        .instr_type(instr_type)
    );
    ImmGen imm_gen(
        .instr(instr), .instr_type(instr_type),

        .imm(imm)
    );
    BranchPredictor br_predictor(
        .imm(imm),
        .br_pred(br_pred)
    );
    assign target_pc = pc + imm;
    assign link_pc = pc + 4;
endmodule

//fwd 00-nofwd 01-fwdM 10-fwdWB
module EX_stage(
    input clk,
    input n_rst,

    input [4:0] ex_rs1_id,
    input [4:0] ex_rs2_id,
    input [4:0] m_rd_id,
    input [4:0] wb_rd_id,
    input [3:0] funct,
    input [6:0] opcode,
    input [2:0] instr_type,

    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] m_rd_data,
    input [31:0] wb_rd_data,
    input [31:0] imm,
    input [1:0] rs1_fwd,
    input [1:0] rs2_fwd,
    input alu_src_imm,
    input alu_op1_zero,
    input alu_op1_pc,
    input [31:0] pc,

    output [31:0] alu_res,
    output [31:0] out_rs1_data,
    output [31:0] out_rs2_data,
    output alu_zero,
    output alu_lt
);
    `include "ALUOps.vh"
    //instr execute

    wire alu_funct_most_bit, funct_shift;
    reg [3:0] alu_funct;

    assign funct_shift = (funct[2:0] == 3'b001 || funct[2:0] == 3'b101);
    assign alu_funct_most_bit = (opcode == `ADD || (opcode == `ADDI && funct_shift)) ? funct[3] : 0;

    always @(*) begin
        if(opcode == `ADD || opcode == `ADDI)
            alu_funct = {alu_funct_most_bit, funct[2:0]};
        else if(opcode == `LW || opcode == `SW || opcode == `JALR || opcode == `LUI || opcode == `AUIPC)
            alu_funct = `ALU_ADD;
        else if(opcode == `BEQ) begin
            if(funct[2:0] == `BEQ_FUNCT || funct[2:0] == `BNE_FUNCT)
                alu_funct = `ALU_SUB;
            else if(funct[2:0] == `BLT_FUNCT || funct[2:0] == `BGE_FUNCT)
                alu_funct = `ALU_SLT;
            else
                alu_funct = `ALU_SLTU;
        end
        else
            alu_funct = 4'b1111;
    end

    //data forwarding
    reg [31:0] fwd_rs1_data, fwd_rs2_data;

    always @(*) begin
        case (rs1_fwd)
            2'b01: fwd_rs1_data = m_rd_data;
            2'b10: fwd_rs1_data = wb_rd_data;
            default: fwd_rs1_data = rs1_data;
        endcase

        case (rs2_fwd)
            2'b01: fwd_rs2_data = m_rd_data;
            2'b10: fwd_rs2_data = wb_rd_data;
            default: fwd_rs2_data = rs2_data;
        endcase
    end
    wire [31:0] alu_op1, alu_op2;
    assign alu_op1 = alu_op1_pc ? pc : (alu_op1_zero ? 0 : fwd_rs1_data);
    assign alu_op2 = alu_src_imm ? imm : fwd_rs2_data;

    //output
    ALU alu(
        .funct(alu_funct), .op1(alu_op1), .op2(alu_op2),

        .res(alu_res), .zero(alu_zero)
    );

    assign out_rs1_data = fwd_rs1_data;
    assign out_rs2_data = fwd_rs2_data;
    assign alu_lt = alu_res[0];
endmodule


module M_stage(
    input clk,
    input n_rst,

    input [31:0] alu_res,
    input [31:0] rs2_data,
    input wr_en_mem,
    input wr_mem_fwd,
    input [31:0] wr_fwd_data,

    output [31:0] rd_mem_data
);
    //instr access mem
    wire [31:0] mem_addr, wr_mem_data;
    assign mem_addr = alu_res;
    assign wr_mem_data = wr_mem_fwd ? wr_fwd_data : rs2_data;

    //output
    RAM ram(
        .clk(clk), .n_rst(n_rst),
        .rd_addr(mem_addr[15:0]), .wr_addr(mem_addr[15:0]),
        .wr_en(wr_en_mem), .wr_data(wr_mem_data),

        .rd_data(rd_mem_data)
    );
endmodule


module WB_stage(
    input mem2reg,
    input pc2reg,
    input [31:0] alu_res,
    input [31:0] link_pc,
    input [31:0] rd_mem_data,

    output reg [31:0] wr_data
);
    //instr writeback
    always @(*) begin
        if(mem2reg)
            wr_data = rd_mem_data;
        else if(pc2reg)
            wr_data = link_pc;
        else
            wr_data = alu_res;
    end
endmodule