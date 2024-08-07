module InstrMem(
    input [9:0] pc,
    output [31:0] instr
);
    reg [31:0] instr_mem [1023:0];
    localparam instr_path = "./test/test_u_bin.txt";
    initial begin
        $readmemh(instr_path, instr_mem, 0, 20);
    end
    assign instr = instr_mem[pc];
endmodule