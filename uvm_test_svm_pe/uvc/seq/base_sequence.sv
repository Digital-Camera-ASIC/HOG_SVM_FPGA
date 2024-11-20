class init_read_seq extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end
  int i_coef_1 = 0;
  int i_coef_2 = 20;
  int i_coef_3 = 40;
  int i_coef_4 = 60;
  logic [40][767:0] fifo;
  logic [287:0] coef [420];
  function new(string name = "init_read_seq");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    string file_path = "C:/Users/datph/Desktop/Thesis/Testing/Hog_gen/Smart_camera_ASIC/uvm_test_svm_pe/uvc/seq/coef.txt";
    $readmemh(file_path, coef);
    $display("coef[0]: %h", coef[0]);
    $display("coef[419]: %h", coef[419]);
  endtask

  virtual task body();
    repeat (500) begin // toi 82 la no van k co error
      
      `uvm_do_with(req,
                   {
                    // foreach (fea_a_r[i]) {
                    //   fea_a_r[i] == cnt;
                    //   fea_b_r[i] == cnt;
                    //   fea_c_r[i] == cnt;
                    //   fea_d_r[i] == cnt;
                    // }
                      coef_a == coef[i_coef_1 % 420];
                      coef_b == coef[i_coef_2 % 420];
                      coef_c == coef[i_coef_3 % 420];
                      coef_d == coef[i_coef_4 % 420];
                   })


      i_coef_1++;
      i_coef_2++;
      i_coef_3++;
      i_coef_4++;
      get_response(rsp);
    end
    repeat (50) begin 

      `uvm_do_with(req,
                   {
                    foreach (fea_a_r[i]) {
                      fea_a_r[i_coef_1%9] == 0;
                      fea_b_r[i_coef_2%9] == 0;
                      fea_c_r[i_coef_3%9] == 0;
                      fea_d_r[i_coef_4%9] == 0;
                    }
                      coef_a == coef[i_coef_1 % 420];
                      coef_b == coef[i_coef_2 % 420];
                      coef_c == coef[i_coef_3 % 420];
                      coef_d == coef[i_coef_4 % 420];
                   })


      i_coef_1++;
      i_coef_2++;
      i_coef_3++;
      i_coef_4++;  

      get_response(rsp);
    end
    repeat (10) begin 
      
      `uvm_do_with(req,
                   {
                      i_data == 0;
                      coef_a == coef[i_coef_1 % 420];
                      coef_b == coef[i_coef_2 % 420];
                      coef_c == coef[i_coef_3 % 420];
                      coef_d == coef[i_coef_4 % 420];
                   })


      i_coef_1++;
      i_coef_2++;
      i_coef_3++;
      i_coef_4++;
      get_response(rsp);
    end
  endtask
endclass
