onerror resume
wave tags  F0
wave update off
wave zoom range 0 38000
wave group top.vif -backgroundcolor #004466
wave add -group top.vif top.vif.DATA_W -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.clk -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.bin -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.i_valid -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.o_valid -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.addr_fw -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.bid -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_a -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_b -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_c -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_d -tag F0 -radix hexadecimal
wave insertion [expr [wave index insertpoint] + 1]
wave update on
wave top 0
