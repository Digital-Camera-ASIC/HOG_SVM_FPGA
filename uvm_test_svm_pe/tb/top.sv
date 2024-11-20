`timescale 1ns / 1ps

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
`include "hog.v"
`include "mag_cal_sbs.v"
`include "mag_cal.v"
`include "normalize.v"
`include "serial_to_parallel.v"
`include "svm_ctrl.v"
`include "svm_pe.v"
`include "svm.v"
`include "tan_decode.v"
// `include "../../hdl/*.v"
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module top;

  bit clk = 0;
  bit rst = 0;
  parameter DATA_W = 768;
  parameter DEPTH = 1;
  parameter cycle = 4;
  `CLK_GEN(clk, cycle);

  dut_if #(
      .FEA_I(4),
      .FEA_F(28)
  ) vif (
      .clk(clk),
      .rst(rst)
  );

svm_pe #(
    .FEA_I      (4),
    // integer part of hog feature
    // fractional part of hog feature
    .FEA_F      (28)
) u_svm_pe (
    .clk        (clk),
    .rst        (rst),
    .fea_a      (vif.fea_a),
    .fea_b      (vif.fea_b),
    .fea_c      (vif.fea_c),
    .fea_d      (vif.fea_d),
    .coef_a     (vif.coef_a),
    .coef_b     (vif.coef_b),
    .coef_c     (vif.coef_c),
    .coef_d     (vif.coef_d),
    .i_data     (vif.i_data),
    .i_valid    (vif.i_valid),
    .o_data     (vif.o_data)
);
  

  
  // always @ (posedge clk) begin
  //   // forever
  //   #1;
  //   if(top.u_hog.u_hog_fetch.valid_r1) begin
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin0_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin20_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin40_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin60_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin80_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin100_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin120_s / (2**16));
  //     $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin140_s / (2**16));
  //     $display("HEHE %f \n", 1.0 *top.u_hog.u_hog_fetch.bin160_s / (2**16));
  //   end
  // end
  
  initial begin
    uvm_config_db#(virtual dut_if)::set(null, "*", "vif", vif);
    run_test();
  end

  initial begin
    rst = 0;
    repeat (5) @vif.cb;
    rst = 1;
  end
endmodule
