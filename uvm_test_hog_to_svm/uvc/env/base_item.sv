class base_item extends uvm_sequence_item;

  rand bit [7:0] data_temp [4];
  logic ready;
  logic request;
  logic [31:0] data;

  logic is_person;
  logic o_valid;
  logic [11:0] result;
  logic [10 : 0] sw_id;
  
  logic [5 : 0] addr_a;
  logic write_en;
  logic [1259 : 0] i_data_a;
  logic [1259 : 0] o_data_a;
  logic [11:0] bias;
  logic b_load;



  `uvm_object_utils_begin(base_item)
    `uvm_field_sarray_int(data_temp, UVM_ALL_ON);
    `uvm_field_int(ready, UVM_ALL_ON);
    `uvm_field_int(request, UVM_ALL_ON);
    `uvm_field_int(data, UVM_ALL_ON);

    `uvm_field_int(o_valid, UVM_ALL_ON);
    `uvm_field_int(result, UVM_ALL_ON);
    `uvm_field_int(sw_id, UVM_ALL_ON);
    `uvm_field_int(is_person, UVM_ALL_ON);
  
    `uvm_field_int (addr_a, UVM_ALL_ON);
    `uvm_field_int (write_en, UVM_ALL_ON);
    `uvm_field_int (i_data_a, UVM_ALL_ON);
    `uvm_field_int (o_data_a, UVM_ALL_ON);
    `uvm_field_int (bias, UVM_ALL_ON);
    `uvm_field_int (b_load, UVM_ALL_ON);
  `uvm_object_utils_end

  function new(string name = "base_item");
    super.new(name);
  endfunction
  
  function void post_randomize();
    for (int i = 0; i < 4; i++) begin
      data[i*8+:8] = data_temp[i];
    end
  endfunction
endclass : base_item
