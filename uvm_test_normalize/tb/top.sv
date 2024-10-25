`timescale 1ns/1ps

`include "apb_if.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
import base_uvm_pkg::*;
`include "base_test.sv"
`include "bin_cal.v"
`include "buffer_ctr.v"
`include "buffer_element.v"
`include "buffer.v"
`include "fxp_div.v"
`include "fxp_sqrt.v"
`include "fxp_zoom.v"
`include "hog_feature_gen.v"
`include "hog_fetch.v"
`include "mag_cal_sbs.v"
`include "normalize.v"
`include "serial_to_parallel.v"
`include "tan_decode.v"

`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module top;

bit clk = 0;
bit rst = 0;
parameter DATA_W = 288;
parameter DEPTH = 1;
parameter cycle = 4;
`CLK_GEN(clk, cycle);

dut_if #(.DATA_W(DATA_W)) vif(.clk(clk), .rst(rst));

hog_feature_gen #(
    .ADDR_W     (13),
    // address width of cells
    .BIN_I      (16),
    // integer part of bin
    .BIN_F      (16),
    // fractional part of bin
    .BID_W      (13),
    // block id width
    .FEA_I      (4),
    // integer part of hog feature
    // fractional part of hog feature
    .FEA_F      (28)
) u_hog_feature_gen (
    .clk        (clk),
    .rst        (rst),
    .addr_fw    (vif.addr_fw),
    .address    (vif.addr),  
    .bin        (vif.bin),
    .i_valid    (vif.i_valid),
    .bid        (vif.bid),
    .fea_a      (vif.fea_a),
    .fea_b      (vif.fea_b),
    .fea_c      (vif.fea_c),
    .fea_d      (vif.fea_d),
    .o_valid    (vif.o_valid)
);

initial begin
    uvm_config_db #(virtual dut_if)::set(null, "*", "vif", vif); 
    run_test();
end

initial begin
    rst = 0;
    repeat(5) @vif.cb;
    rst = 1;
end
endmodule
