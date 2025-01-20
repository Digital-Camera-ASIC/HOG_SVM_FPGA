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
`include "syn_svm.v"

`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module top;

  bit clk = 0;
  bit rst = 0;
  parameter PIX_W = 8;
  parameter MAG_F = 4;
  parameter TAN_I = 4;
  parameter TAN_F = 8;
  parameter BIN_I = 16;
  parameter FEA_I = 4;
  parameter FEA_F = 8;

  parameter cycle = 4;
  `CLK_GEN(clk, cycle);

  dut_if #(
      .PIX_W (PIX_W),
      .MAG_F (MAG_F),
      .TAN_I (TAN_I),
      .TAN_F (TAN_F),
      .BIN_I (BIN_I),
      .FEA_I (FEA_I),
      .FEA_F (FEA_F)
  ) vif (
      .clk(clk),
      .rst(rst)
  );

  hog #(
      .PIX_W (PIX_W),
      .MAG_F (MAG_F),
      .TAN_I (TAN_I),
      .TAN_F (TAN_F),
      .BIN_I (BIN_I),
      .FEA_I (FEA_I),
      .FEA_F (FEA_F)
  ) u_hog (
      .clk    (clk),
      .rst    (rst),
      .ready  (vif.ready),
      .i_data (vif.i_data),
      .request(vif.request),
      .fea    (vif.fea),
      .o_valid(vif.o_valid)
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
