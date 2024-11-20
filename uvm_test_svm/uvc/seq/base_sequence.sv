class init_read_seq extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end

  int cnt = 2**22;

  function new(string name = "init_read_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    repeat (1200) begin // toi 82 la no van k co error
      `uvm_do_with(req,
                   {
                    // foreach (fea_a_r[i]) {
                    //   fea_a_r[i] == cnt;
                    //   fea_b_r[i] == cnt;
                    //   fea_c_r[i] == cnt;
                    //   fea_d_r[i] == cnt;
                    // }
                   })
      cnt++;
      get_response(rsp);
    end
  endtask
endclass
