class init_read_seq extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end
  int cnt = 0;
  logic[767:0] fifo[1200];

  function new(string name = "init_read_seq");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    string file_path = "C:/Users/datph/Desktop/Thesis/Testing/phase_2/HOG_SVM_FPGA/uvm_test_hog_to_svm/pic/test_2.txt";
    $readmemh(file_path, fifo);
    $display("fifo[0]: %h", fifo[0]);
    $display("fifo[1199]: %h", fifo[1199]);
  endtask

//   virtual task body();
//     repeat (1200) begin
//       `uvm_do_with(req,
//                    {
//                     // data == cnt;
//                    })
//       // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
//       cnt++;
//       get_response(rsp);
//     end
// // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
//     cnt = 0;
//     // repeat (1200) begin
//     //   `uvm_do_with(req,
//     //                {
//     //                 // data == cnt;
//     //                })
//     //   // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
//     //   cnt++;
//     //   get_response(rsp);
//     // end
//   endtask

  virtual task body();
    repeat (1200) begin
      `uvm_do_with(req,
                   {
                    data == fifo[cnt];
                   })
      // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
      cnt++;
      get_response(rsp);
    end
  endtask
endclass

class init_read_seq_2 extends uvm_sequence #(base_item);
  base_item req;
  `uvm_object_utils_begin(init_read_seq_2)
    `uvm_field_object(req, UVM_ALL_ON)
  `uvm_object_utils_end
  int cnt = 0;
  logic[767:0] fifo[1200];

  function new(string name = "init_read_seq_2");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    string file_path = "C:/Users/datph/Desktop/Thesis/Testing/phase_2/HOG_SVM_FPGA/uvm_test_hog_to_svm/pic/test_4.txt";
    $readmemh(file_path, fifo);
    $display("fifo[0]: %h", fifo[0]);
    $display("fifo[1199]: %h", fifo[1199]);
  endtask

//   virtual task body();
//     repeat (1200) begin
//       `uvm_do_with(req,
//                    {
//                     // data == cnt;
//                    })
//       // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
//       cnt++;
//       get_response(rsp);
//     end
// // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
//     cnt = 0;
//     // repeat (1200) begin
//     //   `uvm_do_with(req,
//     //                {
//     //                 // data == cnt;
//     //                })
//     //   // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
//     //   cnt++;
//     //   get_response(rsp);
//     // end
//   endtask

  virtual task body();
    repeat (1200) begin
      `uvm_do_with(req,
                   {
                    data == fifo[cnt];
                   })
      // $display("FIFO[%0d]: %h", cnt, fifo[cnt]);
      cnt++;
      get_response(rsp);
    end
  endtask
endclass
