`include "PipeCPU.v"
`timescale 1ns/1ns

module top_tb ();
    parameter N = 10;
    reg clk, n_rst;
    always #(`T / 2) clk = ~clk;

    wire [31:0] n_cycle, n_exe_instr;
    PipeCPU cpu(.clk(clk), .n_rst(n_rst), .n_cycle(n_cycle), .n_exe_instr(n_exe_instr));

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

    initial begin
        clk = 1;
        n_rst = 1;
        #(N * `T)
        $display("Total Cycles: %d, Instr Executed: %d", n_cycle, n_exe_instr);
        $finish;
    end

endmodule