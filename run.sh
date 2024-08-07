cd src
iverilog -o ../tb ./test_cpu.v
vvp -n ../tb
gtkwave ../top_tb.vcd