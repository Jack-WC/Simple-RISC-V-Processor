module RAM(
    input clk,
    input n_rst,
    input [15:0] rd_addr,
    input [15:0] wr_addr,
    input wr_en,
    input [31:0] wr_data,
    output [31:0] rd_data
);
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
                $display("Write Memory: Addr %d, Data %d", wr_addr, wr_data);
                ram[wr_addr] <= wr_data[7:0];
                ram[wr_addr + 1] <= wr_data[15:8];
                ram[wr_addr + 2] <= wr_data[23:16];
                ram[wr_addr + 3] <= wr_data[31:24];
            end
        end
    end

    assign rd_data = {ram[rd_addr + 3], ram[rd_addr + 2], ram[rd_addr + 1], ram[rd_addr]};
endmodule