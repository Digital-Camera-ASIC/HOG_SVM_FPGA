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
`include "hog_svm.v"
`include "hog.v"
`include "mag_cal_sbs.v"
`include "mag_cal.v"
`include "normalize.v"
`include "serial_to_parallel.v"
`include "svm_ctrl.v"
`include "svm_pe.v"
`include "svm.v"
`include "tan_decode.v"


`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module top;

  logic [287:0] coef_temp [420];
  string coef_name;

  bit clk = 0;
  bit rst = 0;
  
  parameter FEA_I = 4;
  parameter FEA_F = 28;
  parameter SW_W  = 11;
  parameter DATA_W = 768;

  parameter cycle = 4;
  `CLK_GEN(clk, cycle);

  dut_if #(
      .FEA_I (FEA_I),
      .FEA_F (FEA_F),
      .SW_W  (SW_W),
      .DATA_W(DATA_W)
  ) vif (
      .clk(clk),
      .rst(rst)
  );

hog_svm #(
    .PIX_W        (8),
    // pixel width
    .PIX_N        (96),
    // the number of pixels
    .MAG_I        (9),
    // integer part of magnitude
    .MAG_F        (16),
    // fraction part of magnitude
    .TAN_W        (19),
    // tan width
    .BIN_I        (16),
    // integer part of bin
    .BIN_F        (16),
    // fractional part of bin
    .ADDR_W       (11),
    // address width of cells
    .FEA_I        (4),
    // integer part of hog feature
    .FEA_F        (28),
    // fractional part of hog feature
    // slide window width
    .SW_W         (11)
) u_hog_svm (
    .clk          (vif.clk),
    .rst          (vif.rst),
    .ready        (vif.ready),
    .i_data       (vif.i_data),
    .request      (vif.request),
    .is_person    (vif.is_person),
    .o_valid      (vif.o_valid),
    .result       (vif.result),
    // slide window index
    .sw_id        (vif.sw_id)
);

  initial begin

    string file_path = "C:/Users/datph/Desktop/Thesis/Testing/Hog_gen/Smart_camera_ASIC/uvm_test_svm/uvc/env/coef.txt";
    $readmemh(file_path, coef_temp);
    for (int i = 0; i < 420; i++) begin
      coef_name = {"coef_", $sformatf("%0d", i)};
      uvm_config_db#(logic [287:0])::set(null, "*", coef_name, coef_temp[i]);
    end

    uvm_config_db#(virtual dut_if)::set(null, "*", "vif", vif);
    run_test();
  end

  initial begin
    rst = 0;
    repeat (5) @vif.cb;
    rst = 1;
  end
endmodule
