class base_item extends uvm_sequence_item;

  parameter FEA_I = 4;
  parameter FEA_F = 28;

  rand bit [31:0] fea_a_r [9];
  rand bit [31:0] fea_b_r [9];
  rand bit [31:0] fea_c_r [9];
  rand bit [31:0] fea_d_r [9];

  // rand bit [31:0] coef_a_r [9];
  // rand bit [31:0] coef_b_r [9];
  // rand bit [31:0] coef_c_r [9];
  // rand bit [31:0] coef_d_r [9];

  logic [287:0] fea_a;
  logic [287:0] fea_b;
  logic [287:0] fea_c;
  logic [287:0] fea_d;

  rand bit [287:0] coef_a;
  rand bit [287:0] coef_b;
  rand bit [287:0] coef_c;
  rand bit [287:0] coef_d;

  rand bit [31:0] i_data;
  logic i_valid;
  logic [31:0] o_data;
  int total_sum = 0;

  constraint value_feature {
    fea_a_r.sum() + fea_b_r.sum() + fea_c_r.sum() + fea_d_r.sum() <= 2**28;
    fea_a_r.sum() <= 2**28;
    fea_b_r.sum() <= 2**28;
    fea_c_r.sum() <= 2**28;
    fea_d_r.sum() <= 2**28;
    foreach(fea_a_r[i]) {
      fea_a_r[i] < 2**28 || fea_a_r[i] > 4026531840 ; // 4026531840 = F000_0000 (-1 -> 0)   |   2**28 (0 -> 1)
      fea_b_r[i] < 2**28 || fea_b_r[i] > 4026531840 ;
      fea_c_r[i] < 2**28 || fea_c_r[i] > 4026531840 ;
      fea_d_r[i] < 2**28 || fea_d_r[i] > 4026531840 ;
    }
  }

  constraint i_data_value {
    i_data < 4*(2**28);
  }

  `uvm_object_utils_begin(base_item)
    `uvm_field_sarray_int(fea_a, UVM_ALL_ON);
    `uvm_field_sarray_int(fea_b, UVM_ALL_ON);
    `uvm_field_sarray_int(fea_c, UVM_ALL_ON);
    `uvm_field_sarray_int(fea_d, UVM_ALL_ON);
    `uvm_field_sarray_int(coef_a, UVM_ALL_ON);
    `uvm_field_sarray_int(coef_b, UVM_ALL_ON);
    `uvm_field_sarray_int(coef_c, UVM_ALL_ON);
    `uvm_field_sarray_int(coef_d, UVM_ALL_ON);
    `uvm_field_int(i_data, UVM_ALL_ON);
    `uvm_field_int(i_valid, UVM_ALL_ON);
    `uvm_field_int(o_data, UVM_ALL_ON);
  `uvm_object_utils_end

  function new(string name = "base_item");
    super.new(name);
  endfunction
  
  function void post_randomize();
    $display("Enter post_randomize");

    for (int i = 0; i < 9; i++) begin
      fea_a[i*32+:32] = fea_a_r[i];
      fea_b[i*32+:32] = fea_b_r[i];
      fea_c[i*32+:32] = fea_c_r[i];
      fea_d[i*32+:32] = fea_d_r[i];
      // coef_a[i*32+:32] = coef_a_r[i];
      // coef_b[i*32+:32] = coef_b_r[i];
      // coef_c[i*32+:32] = coef_c_r[i];
      // coef_d[i*32+:32] = coef_d_r[i];
    end

  endfunction
endclass : base_item
