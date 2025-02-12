`timescale 1ns / 1ps

`include "apb_if.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
import base_uvm_pkg::*;
`include "base_test.sv"
`include "bin_cal.v"
`include "bin_ctr.v"
`include "buffer_ctr.v"
`include "buffer_element.v"
`include "buffer.v"
`include "div.v"
`include "div2.v"
`include "dp_ram.v"
`include "dp_ram2.v"
`include "hog_svm.v"
`include "hog.v"
`include "mag_cal.v"
`include "normalize.v"
`include "sqrt.v"
`include "sum_sq_diff.v"
`include "svm_ctrl.v"
`include "svm_pe.v"
`include "svm.v"

`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module top;

  logic [107:0] coef_temp[420];
  string coef_name;
  string file_path_ram, file_path_bias, file_path;

  bit clk = 0;
  bit rst = 0;

  parameter PIX_W = 8;
  parameter MAG_F = 4;
  parameter TAN_I = 4;
  parameter TAN_F = 16;
  parameter BIN_I = 16;
  parameter FEA_I = 4;
  parameter FEA_F = 8;
  parameter SW_W = 11;

  parameter cycle = 4;
  `CLK_GEN(clk, cycle);

  dut_if #(
      .PIX_W(PIX_W),
      .MAG_F(MAG_F),
      .TAN_I(TAN_I),
      .TAN_F(TAN_F),
      .BIN_I(BIN_I),
      .FEA_I(FEA_I),
      .FEA_F(FEA_F),
      .SW_W (SW_W)
  ) vif (
      .clk(clk),
      .rst(rst)
  );

hog_svm #(
    .PIX_W         (8),
    // pixel width
    .MAG_F         (4),
    // fraction part of magnitude
    .TAN_I         (4),
    // tan width
    .TAN_F         (16),
    // tan width
    .BIN_I         (16),
    // integer part of bin
    .FEA_I         (4),
    // integer part of hog feature
    .FEA_F         (8),
    // fractional part of hog feature
    .SW_W          (11)
    // slide window width
    // .IN_W          (PIX_W*4),
    // .FEA_W         (FEA_I+FEA_F),
    // .COEF_W        (FEA_W),
    // .ROW           (15),
    // .COL           (7),
    // .N_COEF        (ROW*COL),
    // // number of coef in a fetch instruction
    // .RAM_DW        (COEF_W*N_COEF),
    // // ceil of log2(36)
    // .ADDR_W        (6)
) u_hog_svm (
    //// hog if
    .clk           (vif.clk),
    .rst           (vif.rst),
    .ready         (vif.ready),
    .request       (vif.request),
    .i_data_hog    (vif.i_data),
    //// svm if
    // ram interface
    .addr_a        (vif.addr_a),
    .write_en      (vif.write_en),
    .i_data_a      (vif.i_data_a),
    .o_data_a      (vif.o_data_a),
    // bias
    .bias          (vif.bias),
    .b_load        (vif.b_load),
    // output info
    .o_valid       (vif.o_valid),
    .is_person     (vif.is_person),
    .result        (vif.result),
    // slide window index
    .sw_id         (vif.sw_id)
);
  initial begin
    string file_path_ram = "C:/Users/datph/Desktop/Thesis/Testing/phase_2/HOG_SVM_FPGA/uvm_test_svm/uvc/env/coef_2.txt";
    $readmemh(file_path_ram, u_hog_svm.u_svm.u_dp_ram2.ram);
    // file_path_bias = "C:/Users/datph/Desktop/Thesis/Testing/phase_2/HOG_SVM_FPGA/uvm_test_svm/uvc/env/bias.txt";
    // $readmemh(file_path_bias, u_hog_svm.u_svm.bias_r);
    file_path = "C:/Users/datph/Desktop/Thesis/Testing/phase_2/HOG_SVM_FPGA/uvm_test_svm/uvc/env/coef.txt";
    // $display("DEBUG --- TOP");
    $readmemh(file_path, coef_temp);
    $display("SHOW RAM");

    for (int i = 0; i < 64; i++) begin
      $display("Ram[%0d]: %h", i, u_hog_svm.u_svm.u_dp_ram2.ram[i]);
    end

    for (int i = 0; i < 420; i++) begin
      // $display("coef_temp[%0d]: %h", i, coef_temp[i]);
      coef_name = {"coef_", $sformatf("%0d", i)};
      uvm_config_db#(logic [107:0])::set(null, "*", coef_name, coef_temp[i]);
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
