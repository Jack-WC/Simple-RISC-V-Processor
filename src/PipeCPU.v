`include "ALU.v"
`include "InstrMem.v"
`include "RAM.v"
`include "PC.v"
`include "RegFile.v"
`include "Controller.v"
`include "ImmGen.v"
`include "InstrType.v"
`include "stages.v"
`include "PipeRegs.v"

`define T 2

// a simple 5-stage pipelined cpu
module PipeCPU(
    input clk,
    input n_rst,
    output reg [31:0] n_cycle,
    output reg [31:0] n_exe_instr
);
    //datapath
    //pipeline regs
    //pipeline stages
    //IF stage
    wire [31:0] if_instr, if_pc;

    IF_stage if_stage(
        .clk(clk), .n_rst(n_rst),
        .stall(pc_stall),
        .id_opcode(id_opcode),
        .id_target_pc(id_target_pc),
        .ex_opcode(ex_opcode),
        .ex_target_pc(ex_target_pc),
        .ex_br_taken(br_taken),
        .ex_br_pred(ex_br_pred),
        .id_br_pred(id_br_pred),
        .ex_link_pc(ex_link_pc),

        .instr(if_instr),
        .out_pc(if_pc)
    );

    IF_ID_Reg if_id_reg(
        .clk(clk), .n_rst(n_rst), .ctr(if_id_ctr),
        .in_instr(if_instr),
        .in_pc(if_pc),

        .out_instr(id_instr), .out_pc(id_pc)
    );

    //ID stage
    wire [31:0] id_instr, id_pc, id_imm, wr_reg_data, id_rs1_data, id_rs2_data,
        id_target_pc, id_link_pc;
    wire [4:0] id_rs1_id, id_rs2_id, id_rd_id;
    wire [6:0] id_opcode;
    wire [2:0] id_instr_type;
    wire [3:0] id_funct;

    ID_stage id_stage(
        .clk(clk), .n_rst(n_rst),
        .instr(id_instr),
        .pc(id_pc),

        .wb_wr_data(wb_wr_data),
        .wb_wr_id(wb_rd_id),
        .wb_wr_en_reg(wb_wr_en_reg),

        .rs1_id(id_rs1_id),
        .rs2_id(id_rs2_id),
        .out_rd_id(id_rd_id),
        .funct(id_funct),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .imm(id_imm),
        .opcode(id_opcode),
        .instr_type(id_instr_type),
        .target_pc(id_target_pc),
        .link_pc(id_link_pc),
        .br_pred(id_br_pred)
    );

    ID_EX_Reg id_ex_reg(
        .clk(clk), .n_rst(n_rst), .ctr(id_ex_ctr),
        .in_rs1_id(id_rs1_id), .in_rs2_id(id_rs2_id),
        .in_rd_id(id_rd_id),
        .in_rs1_data(id_rs1_data),
        .in_rs2_data(id_rs2_data),
        .in_imm(id_imm),
        .in_opcode(id_opcode),
        .in_pc(id_pc),
        .in_br_pc(id_target_pc),
        .in_link_pc(id_link_pc),
        .in_instr_type(id_instr_type),
        .in_funct(id_funct),
        .in_br_pred(id_br_pred),

        .out_rs1_id(ex_rs1_id), .out_rs2_id(ex_rs2_id),
        .out_rd_id(ex_rd_id),
        .out_rs1_data(ex_rs1_data),
        .out_rs2_data(ex_rs2_data),
        .out_imm(ex_imm),
        .out_opcode(ex_opcode),
        .out_pc(ex_pc),
        .out_br_pc(ex_rel_target_pc),
        .out_link_pc(ex_link_pc),
        .out_instr_type(ex_instr_type),
        .out_funct(ex_funct),
        .out_br_pred(ex_br_pred)
    );

    //EX stage
    wire [4:0] ex_rs1_id, ex_rs2_id, ex_rd_id;
    wire [31:0] ex_rs1_data, ex_rs2_data,
        ex_pc, ex_link_pc, ex_fwd_rs1_data, ex_fwd_rs2_data,
        ex_imm, ex_rel_target_pc, ex_target_pc, ex_alu_res;
    wire [6:0] ex_opcode;
    wire [3:0] ex_funct;
    wire [2:0] ex_instr_type;

    EX_stage ex_stage(
        .clk(clk), .n_rst(n_rst),
        .ex_rs1_id(ex_rs1_id),
        .ex_rs2_id(ex_rs2_id),
        .m_rd_id(m_rd_id),
        .wb_rd_id(wb_rd_id),
        .funct(ex_funct),
        .opcode(ex_opcode),
        .instr_type(ex_instr_type),
        .rs1_data(ex_rs1_data),
        .rs2_data(ex_rs2_data),
        .m_rd_data(m_alu_res),
        .wb_rd_data(wb_wr_data),
        .imm(ex_imm),
        .rs1_fwd(rs1_fwd),
        .rs2_fwd(rs2_fwd),
        .alu_src_imm(alu_src_imm),
        .alu_op1_zero(alu_op1_zero),
        .alu_op1_pc(alu_op1_pc),
        .pc(ex_pc),

        .alu_res(ex_alu_res),
        .alu_zero(ex_alu_zero),
        .alu_lt(ex_alu_lt),
        .out_rs1_data(ex_fwd_rs1_data),
        .out_rs2_data(ex_fwd_rs2_data)
    );
    assign ex_target_pc = (ex_opcode == `JALR) ? ex_alu_res : ex_rel_target_pc;

    EX_M_Reg ex_m_reg(
        .clk(clk), .n_rst(n_rst), .ctr(ex_m_ctr),
        .in_rd_id(ex_rd_id),
        .in_rs2_id(ex_rs2_id),
        .in_rs2_data(ex_fwd_rs2_data),
        .in_pc(ex_link_pc),
        .in_opcode(ex_opcode),
        .in_alu_res(ex_alu_res),
        .in_instr_type(ex_instr_type),

        .out_rd_id(m_rd_id),
        .out_rs2_id(m_rs2_id),
        .out_rs2_data(m_rs2_data),
        .out_pc(m_link_pc),
        .out_opcode(m_opcode),
        .out_alu_res(m_alu_res),
        .out_instr_type(m_instr_type)
    );

    //M stage
    wire [4:0] m_rd_id, m_rs2_id;
    wire [31:0] m_rs2_data, m_link_pc, m_alu_res, m_rd_mem_data;
    wire [6:0] m_opcode;
    wire [2:0] m_instr_type;

    M_stage m_stage(
        .clk(clk), .n_rst(n_rst),
        .alu_res(m_alu_res),
        .rs2_data(m_rs2_data),
        .wr_en_mem(wr_en_mem),
        .wr_mem_fwd(wr_mem_fwd),
        .wr_fwd_data(wb_rd_mem_data),

        .rd_mem_data(m_rd_mem_data)
    );

    M_WB_Reg m_wb_reg(
        .clk(clk), .n_rst(n_rst), .ctr(m_wb_ctr),
        .in_rd_id(m_rd_id),
        .in_pc(m_link_pc),
        .in_opcode(m_opcode),
        .in_rd_mem_data(m_rd_mem_data),
        .in_alu_res(m_alu_res),
        .in_instr_type(m_instr_type),

        .out_rd_id(wb_rd_id),
        .out_pc(wb_link_pc),
        .out_opcode(wb_opcode),
        .out_rd_mem_data(wb_rd_mem_data),
        .out_alu_res(wb_alu_res),
        .out_instr_type(wb_instr_type)
    );

    //WB stage
    wire [4:0] wb_rd_id;
    wire [31:0] wb_alu_res, wb_link_pc, wb_rd_mem_data, wb_wr_data;
    wire [6:0] wb_opcode;
    wire [2:0] wb_instr_type;

    WB_stage wb_stage(
        .mem2reg(mem2reg),
        .pc2reg(pc2reg),
        .alu_res(wb_alu_res),
        .link_pc(wb_link_pc),
        .rd_mem_data(wb_rd_mem_data),

        .wr_data(wb_wr_data)
    );

    //control
    //pipeline regs control signals
    wire pc_stall;
    wire [1:0] if_id_ctr, id_ex_ctr,
        ex_m_ctr, m_wb_ctr,
        rs1_fwd, rs2_fwd;

    //control wires
    wire wr_en_mem, ex_wr_en_reg, wb_wr_en_reg;
    wire alu_src_imm, br_taken, mem2reg, pc2reg;

    //control logic
    Controller controller(
        .alu_zero(ex_alu_zero),
        .alu_lt(ex_alu_lt),
        .br_funct(ex_funct[2:0]),
        .ex_rs1_id(ex_rs1_id),
        .ex_rs2_id(ex_rs2_id),
        .m_rd_id(m_rd_id),
        .m_rs2_id(m_rs2_id),
        .wb_rd_id(wb_rd_id),

        .id_opcode(id_opcode),
        .ex_opcode(ex_opcode),
        .m_opcode(m_opcode),
        .wb_opcode(wb_opcode),
        .ex_br_pred(ex_br_pred),

        .alu_src_imm(alu_src_imm),
        .wr_mem(wr_en_mem),
        .wb_wr_reg(wb_wr_en_reg),
        .br_taken(br_taken),
        .mem2reg(mem2reg),
        .pc2reg(pc2reg),
        .rs1_fwd(rs1_fwd),
        .rs2_fwd(rs2_fwd),
        .wr_mem_fwd(wr_mem_fwd),
        .pc_stall(pc_stall),
        .if_id_ctr(if_id_ctr),
        .id_ex_ctr(id_ex_ctr),
        .ex_m_ctr(ex_m_ctr),
        .m_wb_ctr(m_wb_ctr),
        .alu_op1_zero(alu_op1_zero),
        .alu_op1_pc(alu_op1_pc)
    );

    initial begin
        n_cycle = 0;
        n_exe_instr = 0;
    end

    always @(posedge clk) begin
        $strobe("Cycle: %d", n_cycle);
        $strobe("current pc: %d", if_pc);
        $strobe("current instr: %h", if_instr);

        // $strobe("ID stage:");
        $strobe("ID opcode: %b", id_opcode);
        $strobe("Rs1_id: %d Rs1_data: %d", id_rs1_id, id_rs1_data);
        $strobe("Rs2_id: %d, Rs2_data: %d", id_rs2_id, id_rs2_data);
        $strobe("Imm: %d", id_imm);

        // $strobe("EX stage:");
        $strobe("EX opcode: %b", ex_opcode);
        // $strobe("Rs1 id: %d, Rs2 id: %d", ex_rs1_id, ex_rs2_id);
        // $strobe("Rs1 data: %d, Rs2 data: %d", ex_rs1_data, ex_rs2_data);
        $strobe("Rs1 fwd data: %d, Rs2 fwd data: %d", ex_fwd_rs1_data, ex_fwd_rs2_data);
        $strobe("Imm: %d", ex_imm);
        $strobe("ALU Res: %d", ex_alu_res);
        $strobe("Target PC: %d", ex_target_pc);
        $strobe("Branch taken: %d, ID Predict: %d, EX Predict: %d", br_taken, id_br_pred, ex_br_pred);
        // $strobe("Rel PC: %d", ex_rel_target_pc);
        // $strobe("Write Reg: %d, Data: %d", wb_rd_id, wb_wr_data);

        // $strobe("M stage:");
        // $strobe("M opcode: %b, M rd_id %d", m_opcode, m_rd_id);

        // $strobe("WB stage:");
        // $strobe("WB opcode: %b, WB data: %d", wb_opcode, wb_wr_data);

        // $strobe("Control signals:");
        $strobe("wr_en_reg: %d, alu_src_imm: %d", wb_wr_en_reg, alu_src_imm);
        // $strobe("WR Mem Fwd: %d", wr_mem_fwd);

        // $strobe("Forward signals: rs1_fwd: %d, rs2_fwd: %d", rs1_fwd, rs2_fwd);
        // $strobe("Pipeline Register States: PC stall %d IF/ID %d, ID/EX %d, EX/M %d, M/WB %d",
        //     pc_stall, if_id_ctr, id_ex_ctr, ex_m_ctr, m_wb_ctr);
        $strobe("\n");
        n_cycle <= n_cycle + 1;
        if(wb_opcode != 0)
            n_exe_instr <= n_exe_instr + 1;
    end

endmodule