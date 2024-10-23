class base_item extends uvm_sequence_item;

  rand bit [8:0] [31:0] r_bin;
  logic i_valid;
  logic o_valid;
  logic [12:0] addr_fw;
  logic [12:0] bid;
  logic [287:0] fea_a;
  logic [287:0] fea_b;
  logic [287:0] fea_c;
  logic [287:0] fea_d;
  rand bit [12:0]  addr;

    constraint limit {
      r_bin[0][31] == 0;
      r_bin[1][31] == 0;
      r_bin[2][31] == 0;
      r_bin[3][31] == 0;
      r_bin[4][31] == 0;
      r_bin[5][31] == 0;
      r_bin[6][31] == 0;
      r_bin[7][31] == 0;
      r_bin[8][31] == 0;
      (r_bin[0] >> 16) + 
      (r_bin[1] >> 16) + 
      (r_bin[2] >> 16) + 
      (r_bin[3] >> 16) + 
      (r_bin[4] >> 16) + 
      (r_bin[5] >> 16) + 
      (r_bin[6] >> 16) + 
      (r_bin[7] >> 16) + 
      (r_bin[8] >> 16) < 23079;
  }
    
  `uvm_object_utils_begin(base_item)
    `uvm_field_int(r_bin, UVM_ALL_ON);
    `uvm_field_int(i_valid, UVM_ALL_ON);
    `uvm_field_int(o_valid, UVM_ALL_ON);
    `uvm_field_int(addr_fw, UVM_ALL_ON);
    `uvm_field_int(bid, UVM_ALL_ON);
    `uvm_field_int(fea_a, UVM_ALL_ON);
    `uvm_field_int(fea_b, UVM_ALL_ON);
    `uvm_field_int(fea_c, UVM_ALL_ON);
    `uvm_field_int(fea_d, UVM_ALL_ON);
    `uvm_field_int(addr, UVM_ALL_ON);
  `uvm_object_utils_end

  function new(string name = "base_item");
    super.new(name);
  endfunction
endclass : base_item