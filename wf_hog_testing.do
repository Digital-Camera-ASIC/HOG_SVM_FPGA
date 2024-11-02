onerror resume
wave tags F0
wave update off
wave zoom range 0 232000
wave add top.clk -tag F0 -radix hexadecimal
wave add top.rst -tag F0 -radix hexadecimal
wave add top.vif.ready -tag F0 -radix hexadecimal
wave add top.vif.i_data -tag F0 -radix decimal -select
wave add top.vif.request -tag F0 -radix hexadecimal
wave add top.vif.o_valid -tag F0 -radix hexadecimal
wave add top.vif.bid -tag F0 -radix hexadecimal
wave add top.vif.fea_a -tag F0 -radix hexadecimal
wave add top.vif.fea_b -tag F0 -radix hexadecimal
wave add top.vif.fea_c -tag F0 -radix hexadecimal
wave add top.vif.fea_d -tag F0 -radix hexadecimal
wave update on
wave top 0
