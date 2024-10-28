class base_item extends uvm_sequence_item;

  rand bit [767:0] data;
  logic ready;
  logic request;

  logic o_valid;
  logic [12:0] bid;
  logic [287:0] fea_a;
  logic [287:0] fea_b;
  logic [287:0] fea_c;
  logic [287:0] fea_d;

  `uvm_object_utils_begin(base_item)
    `uvm_field_int(data, UVM_ALL_ON);
    `uvm_field_int(request, UVM_ALL_ON);
    `uvm_field_int(ready, UVM_ALL_ON);
    `uvm_field_int(o_valid, UVM_ALL_ON);
    `uvm_field_int(bid, UVM_ALL_ON);
    `uvm_field_int(fea_a, UVM_ALL_ON);
    `uvm_field_int(fea_b, UVM_ALL_ON);
    `uvm_field_int(fea_c, UVM_ALL_ON);
    `uvm_field_int(fea_d, UVM_ALL_ON);
  `uvm_object_utils_end

  function new(string name = "base_item");
    super.new(name);
  endfunction
  
endclass : base_item
