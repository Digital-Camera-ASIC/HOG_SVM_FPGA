class init_read_seq extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end
  int cnt = 0;
  logic [40][767:0] fifo;
  function new(string name = "init_read_seq");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    for (int i = 0; i < 40; i++) begin
      fifo[i] = 0;
    end
  endtask

  virtual task body();
    repeat (10) begin
      `uvm_do_with(req, {

      })
      get_response(req); 
    end

    repeat (76790) begin // toi 82 la no van k co error
      `uvm_do_with(req,
                   {
                      req.data_temp[0] == 0;
                      req.data_temp[1] == 0;
                      req.data_temp[2] == 0;
                      req.data_temp[3] == 0;

                   })


      // for (int j = 39; j > 0; j--) begin
      //   fifo[j] = fifo[j-1];
      // end      
      // fifo[0] = req.data;
      // $display("fifo[0]: captured hehe %h", fifo[0]);
      cnt++;

      get_response(rsp);
    end
  endtask
endclass
