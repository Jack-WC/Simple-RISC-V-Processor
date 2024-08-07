`define NORMAL 2'b00
`define STALL 2'b01
`define BUBBLE 2'b10


module Controller(
    input [2:0] br_funct,
    input alu_zero,
    input alu_lt,
    input [4:0] ex_rs1_id,
    input [4:0] ex_rs2_id,
    input [4:0] m_rd_id,
    input [4:0] m_rs2_id,
    input [4:0] wb_rd_id,

    input [6:0] id_opcode,
    input [6:0] ex_opcode,
    input [6:0] m_opcode,
    input [6:0] wb_opcode,
    input ex_br_pred,
    input id_br_pred,

    output alu_src_imm,
    output alu_op1_zero,
    output alu_op1_pc,
    output wr_mem,
    output wb_wr_reg,
    output reg br_taken,
    output mem2reg,
    output pc2reg,
    output reg [1:0] rs1_fwd,
    output reg [1:0] rs2_fwd,
    output wr_mem_fwd,

    output reg pc_stall,
    output reg [1:0] if_id_ctr,
    output reg [1:0] id_ex_ctr,
    output reg [1:0] ex_m_ctr,
    output reg [1:0] m_wb_ctr
);
    `include "constants.vh"

    wire [2:0] ex_instr_type, wb_instr_type;
    InstrType ex_inst_ty(.opcode(ex_opcode), .instr_type(ex_instr_type));
    InstrType wb_inst_ty(.opcode(wb_opcode), .instr_type(wb_instr_type));

    assign alu_src_imm = (ex_instr_type == `I || ex_instr_type == `U || ex_instr_type == `S);
    assign wr_mem = (m_opcode == `SD);
    assign wb_wr_reg = (wb_instr_type == `R || wb_instr_type == `I || wb_instr_type == `U || wb_instr_type == `J);
    assign mem2reg = (wb_opcode == `LD);
    assign pc2reg = (wb_opcode == `JALR || wb_opcode == `JAL);
    assign alu_op1_zero = (ex_opcode == `LUI);
    assign alu_op1_pc = (ex_opcode == `AUIPC);

    //data forwarding control
    //forward data from m/wb to ex
    always @(*) begin
        if(ex_rs1_id == m_rd_id && m_opcode != `LW && m_opcode != 0 && ex_rs1_id != 0) begin
            rs1_fwd = 2'b01;
        end
        else if(ex_rs1_id == wb_rd_id && wb_opcode != 0 && ex_rs1_id != 0) begin
            rs1_fwd = 2'b10;
        end
        else
            rs1_fwd = 2'b00;

        if(ex_rs2_id == m_rd_id && m_opcode != `LW && m_opcode != 0 && ex_rs2_id != 0) begin
            rs2_fwd = 2'b01;
        end
        else if(ex_rs2_id == wb_rd_id && wb_opcode != 0 && ex_rs2_id != 0) begin
            rs2_fwd = 2'b10;
        end
        else
            rs2_fwd = 2'b00;
    end
    //lw-sw forwarding wb to m
    assign wr_mem_fwd = (m_rs2_id == wb_rd_id && m_opcode == `SW && wb_opcode == `LW) ? 1 : 0;

    //manage pipe regs controls
    //special case: consider lw r0, 0(x0) sw r0, 1(x0)
    //no need to stall
    assign load_stall = (m_opcode == `LW && (m_rd_id == ex_rs1_id || (m_rd_id == ex_rs2_id && ex_opcode != `SW))) ? 1 : 0;

    //branch pred
    assign br_mispred = (ex_opcode == `BEQ && br_taken != ex_br_pred) ? 1 : 0;
    assign br_pred_taken = (id_opcode == `BEQ && id_br_pred) ? 1 : 0;
    assign jal = (id_opcode == `JAL) ? 1 : 0;
    assign jalr = (ex_opcode == `JALR) ? 1 : 0;

    always @(*) begin
        if(load_stall) begin
            pc_stall = 1'b1;
            if_id_ctr = `STALL;
            id_ex_ctr = `STALL;
            ex_m_ctr = `BUBBLE;
            m_wb_ctr = `NORMAL;
        end
        else if(br_mispred || jalr) begin
            pc_stall = 1'b0;
            if_id_ctr = `BUBBLE;
            id_ex_ctr = `BUBBLE;
            ex_m_ctr = `NORMAL;
            m_wb_ctr = `NORMAL;
        end
        else if(jal || br_pred_taken) begin
            pc_stall = 1'b0;
            if_id_ctr = `BUBBLE;
            id_ex_ctr = `NORMAL;
            ex_m_ctr = `NORMAL;
            m_wb_ctr = `NORMAL;
        end
        else begin
            pc_stall = 1'b0;
            if_id_ctr = `NORMAL;
            id_ex_ctr = `NORMAL;
            ex_m_ctr = `NORMAL;
            m_wb_ctr = `NORMAL;
        end
    end

    //branch judge
    always @(*) begin
        case(br_funct)
            `BEQ_FUNCT: begin
                br_taken = alu_zero;
            end
            `BNE_FUNCT: begin
                br_taken = !alu_zero;
            end
            `BLT_FUNCT: begin
                br_taken = alu_lt;
            end
            `BGE_FUNCT: begin
                br_taken = !alu_lt;
            end
            `BLTU_FUNCT: begin
                br_taken = alu_lt;
            end
            `BGEU_FUNCT: begin
                br_taken = !alu_lt;
            end
            default: br_taken = 0;
        endcase
    end
endmodule