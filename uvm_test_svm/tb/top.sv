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
`include "../coef_container.sv"
// `include "../../hdl/*.v"
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
   

module top;

  
  // coef_container my_coef_container;
  // coef_container coef_temp_2;


  logic [287:0] coef_temp [420];
  string coef_name;

  bit clk = 0;
  bit rst = 0;

  parameter cycle = 4;
  `CLK_GEN(clk, cycle);

  dut_if #(
      .FEA_I(4),
      .FEA_F(28),
      .SW_W(11)
  ) vif (
      .clk(clk),
      .rst(rst)
  );

svm #(
    .FEA_I        (4),
    // integer part of hog feature
    .FEA_F        (28),
    // fractional part of hog feature
    // slide window width
    .SW_W         (11)
) u_svm (
    .clk          (clk),
    .rst          (rst),
    .fea_a        (vif.fea_a),
    .fea_b        (vif.fea_b),
    .fea_c        (vif.fea_c),
    .fea_d        (vif.fea_d),
    .i_valid      (vif.i_valid),
    .is_person    (vif.is_person),
    .o_valid      (vif.o_valid),
    .result       (vif.result),
    // slide window index
    .sw_id        (vif.sw_id)
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
    string file_path = "C:/Users/datph/Desktop/Thesis/Testing/Hog_gen/Smart_camera_ASIC/uvm_test_svm/uvc/env/coef.txt";
    $readmemh(file_path, coef_temp);
    // my_coef_container = new();
    // for (int i = 0; i < 420; i++) begin
    //   my_coef_container.coef[i] = coef_temp[i];
    // end
    // uvm_config_db#(coef_container)::set(null, "*", "coef_data", my_coef_container);
    for (int i = 0; i < 420; i++) begin
      coef_name = {"coef_", $sformatf("%0d", i)};
      uvm_config_db#(logic [287:0])::set(null, "*", coef_name, coef_temp[i]);
    end


    // if (!uvm_config_db #(coef_container)::get(null, "", "coef_data", coef_temp_2)) begin
    //     $display("Cau hinh ko thanh cong.");
    // end else begin
    //     $display("Cau hinh thanh cong ");
    //     $display("coef_temp_2.coef[0]: %h", coef_temp_2.coef[0]);
    // end



    uvm_config_db#(virtual dut_if)::set(null, "*", "vif", vif);



    run_test();
  end

  initial begin
    rst = 0;
    repeat (5) @vif.cb;
    rst = 1;
  end
endmodule
