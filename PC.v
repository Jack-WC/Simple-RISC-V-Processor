module PC(
    input clk,
    input n_rst,
    input [31:0] next_pc,
    output reg [31:0] out_pc
);
    initial begin
        out_pc = 0;
    end

    always @(posedge clk or negedge n_rst) begin
        if(!n_rst)
            out_pc <= 0;
        else
            out_pc <= next_pc;
    end
endmodule