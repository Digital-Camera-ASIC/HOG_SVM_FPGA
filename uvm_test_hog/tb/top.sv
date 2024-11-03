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
`include "tan_decode.v"

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
      .DATA_W(DATA_W)
  ) vif (
      .clk(clk),
      .rst(rst)
  );

  hog #(
      .PIX_W (8),
      // pixel width
      .PIX_N (96),
      // the number of pixels
      .MAG_I (9),
      // integer part of magnitude
      .MAG_F (16),
      // fraction part of magnitude
      .TAN_W (19),
      // tan width
      .BIN_I (16),
      // integer part of bin
      .BIN_F (16),
      // fractional part of bin
      .ADDR_W(10),
      // address width of cells
      .BID_W (13),
      // block id width
      .FEA_I (4),
      // integer part of hog feature
      // fractional part of hog feature
      .FEA_F (28)
  ) u_hog (
      .clk    (clk),
      .rst    (rst),
      .ready  (vif.ready),
      .i_data (vif.i_data),
      .request(vif.request),
      .bid    (vif.bid),
      .fea_a  (vif.fea_a),
      .fea_b  (vif.fea_b),
      .fea_c  (vif.fea_c),
      .fea_d  (vif.fea_d),
      .o_valid(vif.o_valid)
  );
  always @ (posedge clk) begin
    // forever
    #1;
    if(top.u_hog.u_hog_fetch.valid_r1) begin
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin0_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin20_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin40_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin60_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin80_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin100_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin120_s / (2**16));
      $display("HEHE %f", 1.0 * top.u_hog.u_hog_fetch.bin140_s / (2**16));
      $display("HEHE %f \n", 1.0 *top.u_hog.u_hog_fetch.bin160_s / (2**16));
    end
  end
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
