module RegFile(
    input clk,
    input n_rst,
    input [4:0] rs1_id,
    input [4:0] rs2_id,

    input wb_wr_en,
    input [4:0] wb_wr_id,
    input [31:0] wb_wr_data,

    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [31:0] r5_data
);

    reg [31:0] regs [31:0];
    integer i;
    always @(negedge clk or negedge n_rst) begin
        if(!n_rst) begin
            for(i = 1; i < 32; i = i + 1) begin
                regs[i] <= 0;
            end
        end
        else begin
            //2 write ports, if ex and wb write conflicts, write ex
            if(wb_wr_en && wb_wr_id != 0) begin
                $display("Write Reg: %d, Data: %d", wb_wr_id, wb_wr_data);
                regs[wb_wr_id] <= wb_wr_data;
            end
        end
    end

    assign rs1_data = (rs1_id == 0) ? 0 : regs[rs1_id];
    assign rs2_data = (rs2_id == 0) ? 0 : regs[rs2_id];
    assign r5_data = regs[5];
endmodule