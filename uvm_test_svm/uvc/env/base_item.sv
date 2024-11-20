class base_item extends uvm_sequence_item;

  rand bit [31:0] fea_a_r [9];
  rand bit [31:0] fea_b_r [9];
  rand bit [31:0] fea_c_r [9];
  rand bit [31:0] fea_d_r [9];

  logic [287:0] fea_a;
  logic [287:0] fea_b;
  logic [287:0] fea_c;
  logic [287:0] fea_d;

  logic i_valid;

  logic is_person;
  logic o_valid;
  logic [31:0] result;
  logic [10:0] sw_id;

  constraint value_feature {
    fea_a_r.sum() + fea_b_r.sum() + fea_c_r.sum() + fea_d_r.sum() <= 2**27;
    fea_a_r.sum() <= 2**27;
    fea_b_r.sum() <= 2**27;
    fea_c_r.sum() <= 2**27;
    fea_d_r.sum() <= 2**27;
    foreach(fea_a_r[i]) {
      fea_a_r[i] < 2**27 || fea_a_r[i] > 4026531840 ; // 4026531840 = F000_0000 (-1 -> 0)   |   2**28 (0 -> 1)
      fea_b_r[i] < 2**27 || fea_b_r[i] > 4026531840 ;
      fea_c_r[i] < 2**27 || fea_c_r[i] > 4026531840 ;
      fea_d_r[i] < 2**27 || fea_d_r[i] > 4026531840 ;
    }
  }

  `uvm_object_utils_begin(base_item)
    `uvm_field_sarray_int(fea_a, UVM_ALL_ON);
    `uvm_field_sarray_int(fea_b, UVM_ALL_ON);
    `uvm_field_sarray_int(fea_c, UVM_ALL_ON);
    `uvm_field_sarray_int(fea_d, UVM_ALL_ON);
    `uvm_field_int(i_valid, UVM_ALL_ON);
    `uvm_field_int(o_valid, UVM_ALL_ON);
    `uvm_field_int(is_person, UVM_ALL_ON);
    `uvm_field_int(result, UVM_ALL_ON);
    `uvm_field_int(sw_id, UVM_ALL_ON);
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
    end

  endfunction
endclass : base_item
