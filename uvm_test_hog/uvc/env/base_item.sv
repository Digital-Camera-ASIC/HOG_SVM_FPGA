class base_item extends uvm_sequence_item;

  parameter int FEA_I = 4;
  parameter int FEA_F = 12;
  rand bit [7:0] data_temp [4];
  logic i_valid;
  logic [31:0] data;
  logic o_valid;
  logic [FEA_I + FEA_F - 1:0] fea;

  `uvm_object_utils_begin(base_item)
    `uvm_field_sarray_int(data_temp, UVM_ALL_ON);
    `uvm_field_int(i_valid, UVM_ALL_ON);
    `uvm_field_int(o_valid, UVM_ALL_ON);
    `uvm_field_int(data, UVM_ALL_ON);
    `uvm_field_int(fea, UVM_ALL_ON);
  `uvm_object_utils_end

  // constraint data_range{
  //   data_temp[0] < 7;
  //   data_temp[1] < 7;
  //   data_temp[2] < 7;
  //   data_temp[3] < 7;
  // }

  function new(string name = "base_item");
    super.new(name);
  endfunction
  

  function void post_randomize();
    // $display("Enter post_randomize");
    for (int i = 0; i < 4; i++) begin
      data[i*8+:8] = data_temp[i];
    end
    // $display("data assign: %h", data);
  endfunction
endclass : base_item
