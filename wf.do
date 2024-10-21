onerror resume
wave tags  F0
wave update off
wave zoom range 0 224000
wave group top.vif -backgroundcolor #004466
wave add -group top.vif top.vif.DATA_W -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.clk -tag F0 -radix hexadecimal
wave add -group top.vif top.u_hog_feature_gen.rst -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.bin -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.i_valid -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.o_valid -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.addr_fw -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.bid -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_a -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_b -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_c -tag F0 -radix hexadecimal
wave add -group top.vif top.vif.fea_d -tag F0 -radix hexadecimal
wave add -group top.vif top.u_hog_feature_gen.one_line_buffer.o_data -tag F0 -radix hexadecimal
wave add -group top.vif top.u_hog_feature_gen.one_line_buffer.o_valid -tag F0 -radix hexadecimal
wave add -group top.vif top.u_hog_feature_gen.one_cell_buffer.o_data -tag F0 -radix hexadecimal
wave insertion [expr [wave index insertpoint] + 1]
wave add top.u_hog_feature_gen.one_cell_buffer.o_valid -tag F0 -radix hexadecimal
wave add top.u_hog_feature_gen.is_addr_valid -tag F0 -radix hexadecimal
wave add top.u_hog_feature_gen.is_addr_valid -tag F0 -radix hexadecimal -select
wave update on
wave top 0
