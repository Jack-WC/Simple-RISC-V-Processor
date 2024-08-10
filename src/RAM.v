module RAM(
    input clk,
    input n_rst,
    input [15:0] rd_addr,
    input [2:0] rd_funct,
    input wr_en,
    input [15:0] wr_addr,
    input [31:0] wr_data,
    input [2:0] wr_funct,
    output reg [31:0] rd_data
);
    `include "constants.vh"

    localparam ram_len = 1 << 16;
    reg [7:0] ram [ram_len - 1:0];
    integer i;

    always @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            for(i = 0; i < ram_len; i = i + 1) begin
                ram[i] <= 0;
            end
        end
        else begin
            if(wr_en) begin
                case(wr_funct)
                    `SB: begin
                        $display("SB: Addr %d, Data %d", wr_addr, wr_data);
                        ram[wr_addr] <= wr_data[7:0];
                    end
                    `SH: begin
                        $display("SH: Addr %d, Data %d", wr_addr, wr_data);
                        ram[wr_addr] <= wr_data[7:0];
                        ram[wr_addr + 1] <= wr_data[15:8];
                    end
                    `SW: begin
                        $display("SW: Addr %d, Data %d", wr_addr, wr_data);
                        ram[wr_addr] <= wr_data[7:0];
                        ram[wr_addr + 1] <= wr_data[15:8];
                        ram[wr_addr + 2] <= wr_data[23:16];
                        ram[wr_addr + 3] <= wr_data[31:24];
                    end
                endcase
            end
        end
    end

    assign rw_data = {ram[rd_addr + 3], ram[rd_addr + 2], ram[rd_addr + 1], ram[rd_addr]};
    assign rh_data = {{16{ram[rd_addr + 1][15]}}, ram[rd_addr + 1], ram[rd_addr]};
    assign rhu_data = {16'b0, ram[rd_addr + 1], ram[rd_addr]};
    assign rb_data = {{24{ram[rd_addr + 1][7]}}, ram[rd_addr]};
    assign rbu_data = {24'b0, ram[rd_addr]};

    always @(*) begin
        case(rd_funct)
            `LB: rd_data = rb_data;
            `LBU: rd_data = rbu_data;
            `LH: rd_data = rh_data;
            `LHU: rd_data = rhu_data;
            default: rd_data = rw_data;
        endcase
    end
endmodule