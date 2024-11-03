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
    repeat (100) begin // toi 82 la no van k co error
      // `uvm_do_with(req,
      //              {
      //             foreach (data_temp[i]) {
      //               if (i < 0|| i > 95 || i % 8 == 0 || i % 8 == 7) {
      //                 data_temp[i] == 0;
      //               }
      //               else {
      //                 data_temp[i] == cnt + i;
      //               }
      //             }
      //           })
      // cnt++;
      `uvm_do_with(req,
                   {

                    foreach (data_temp[i]) {
                      // if (i < 49|| i > 62 || i % 8 == 0 || i % 8 == 7) {
                      if (i < 72 || i > 79) {
                        data_temp[i] == 0;
                      }
                      else {
                        data_temp[i] == cnt + i;
                      }

                    }

                    // data_temp[64] == fifo[39][56*8+:8];
                    // data_temp[65] == fifo[39][57*8+:8];
                    // data_temp[66] == fifo[39][58*8+:8];
                    // data_temp[67] == fifo[39][59*8+:8];
                    // data_temp[68] == fifo[39][60*8+:8];
                    // data_temp[69] == fifo[39][61*8+:8];
                    // data_temp[70] == fifo[39][62*8+:8];
                    // data_temp[71] == fifo[39][63*8+:8];


                    // if (cnt % 40 == 1) {
                    //   data_temp[72] == 0;
                    //   data_temp[73] == 0;
                    //   data_temp[74] == 0;
                    //   data_temp[75] == 0;
                    //   data_temp[76] == 0;
                    //   data_temp[77] == 0;
                    //   data_temp[78] == 0;
                    //   data_temp[79] == 0;
                    // }  

                    // if (cnt % 40 == 0) {
                    //   data_temp[80] == 0;
                    //   data_temp[81] == 0;
                    //   data_temp[82] == 0;
                    //   data_temp[83] == 0;
                    //   data_temp[84] == 0;
                    //   data_temp[85] == 0;
                    //   data_temp[86] == 0;
                    //   data_temp[87] == 0;
                    // }

                    // data_temp[0] == fifo[0][80*8+:8];
                    // data_temp[8] == fifo[0][81*8+:8];
                    // data_temp[16] == fifo[0][82*8+:8];
                    // data_temp[24] == fifo[0][83*8+:8];
                    // data_temp[32] == fifo[0][84*8+:8];
                    // data_temp[40] == fifo[0][85*8+:8];
                    // data_temp[48] == fifo[0][86*8+:8];
                    // data_temp[56] == fifo[0][87*8+:8];

                   })


      for (int j = 39; j > 0; j--) begin
        fifo[j] = fifo[j-1];
      end      
      fifo[0] = req.data;
      // $display("fifo[0]: captured hehe %h", fifo[0]);
      cnt++;

      get_response(rsp);
    end
  endtask
endclass
