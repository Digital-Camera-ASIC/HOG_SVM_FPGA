class init_read_seq extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end
  int cnt = 0;
  function new(string name = "init_read_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    repeat (50) begin
      `uvm_do_with(req,
                   {
                  //  req.data[72+:8] == cnt;
                  //  req.data[0+:72] == 0;
                  //  req.data[80+:688] == 0;
                  // req.data_temp.size() == 96;
                  foreach (data_temp[i]) {
                    if ( (i < 9 || i > 14) && i != 17 ) {
                      data_temp[i] == 0;
                    }
                    else {
                      data_temp[i] == cnt;
                    }
                  }
                  // foreach (data_temp[i]) {
                  //   if ((i >= 0 && i <=8) ||
                  //       (i >= 23 && i <= 95) ||
                  //       (i % 8 == 0) ||
                  //       (i + 1 % 8 == 0)
                  //   )
                  //   // if  (i < 41 || i > 46)
                  //    data_temp[i] == 0;
                  // }
                  //  req.data = cnt;
                   
                })

      // `uvm_do(req);
      // req = base_item::type_id::create("req");
      // req.randomize() with {

      // };
      cnt++;
      // `uvm_do(req);
      get_response(rsp);
    end
  endtask
endclass
