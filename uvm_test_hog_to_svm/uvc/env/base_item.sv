class base_item extends uvm_sequence_item;
  parameter FEA_I = 4;
  parameter FEA_F = 28;
  parameter SW_W  = 11;

  rand bit [7:0] data_temp [96];
  logic ready;
  logic request;
  logic [767:0] data;

  logic is_person;
  logic o_valid;
  logic [(FEA_I + FEA_F - 1) : 0] result;
  logic [           SW_W - 1 : 0] sw_id;
  


  `uvm_object_utils_begin(base_item)
    `uvm_field_sarray_int(data_temp, UVM_ALL_ON);
    `uvm_field_int(request, UVM_ALL_ON);
    `uvm_field_int(ready, UVM_ALL_ON);
    `uvm_field_int(o_valid, UVM_ALL_ON);
    `uvm_field_int(data, UVM_ALL_ON);
    `uvm_field_int(result, UVM_ALL_ON);
    `uvm_field_int(sw_id, UVM_ALL_ON);
    `uvm_field_int(is_person, UVM_ALL_ON);
  `uvm_object_utils_end

  function new(string name = "base_item");
    super.new(name);
  endfunction
  
  function void post_randomize();
    for (int i = 0; i < 96; i++) begin
      data[i*8+:8] = data_temp[i];
    end
  endfunction
endclass : base_item
