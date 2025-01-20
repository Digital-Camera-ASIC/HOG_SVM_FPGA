class init_read_seq extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end
  int cnt = 0;
  int cnt_2 = 0;
  function new(string name = "init_read_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    repeat (2880) begin // 45 cells * 64 pixels
      `uvm_do_with(req,
                   {
                    data_temp[0] == cnt + 5;
                    data_temp[1] == 0;
                    data_temp[2] == cnt + 8;
                    data_temp[3] == 0;
                   }) 
      cnt_2 = cnt_2 + 1;
      if (cnt_2 % 64 == 0) cnt = cnt + 1;
      if (cnt == 255) begin
        cnt = 0;
      end
      get_response(rsp);
    end
  endtask
endclass
