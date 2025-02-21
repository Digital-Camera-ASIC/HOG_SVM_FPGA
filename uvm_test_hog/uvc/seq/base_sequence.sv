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
    // `uvm_do_with(req,
    //              {
    //               // right
    //               data_temp[0] == 0;

    //               //left
    //               data_temp[1] == 0;

    //               //bot
    //               data_temp[2] == 159;

    //               //top
    //               data_temp[3] == 0;
    //              })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 0;

    //             //left
    //             data_temp[1] == 86;

    //             //bot
    //             data_temp[2] == 0;

    //             //top
    //             data_temp[3] == 67;
    //             })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 0;

    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 159;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);


    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 0;

    //             //left
    //             data_temp[1] == 30;

    //             //bot
    //             data_temp[2] == 0;

    //             //top
    //             data_temp[3] == 62;
    //             })

    // get_response(rsp);


    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 97;
    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 210;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 0;

    //             //left
    //             data_temp[1] == 130;

    //             //bot
    //             data_temp[2] == 122;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);


    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 11;

    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 33;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 124;

    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 157;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 125;

    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 0;

    //             //top
    //             data_temp[3] == 162;
    //             })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 125;

    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 0;

    //             //top
    //             data_temp[3] == 162;
    //             })

    // get_response(rsp);


    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 0;

    //             //left
    //             data_temp[1] == 34;

    //             //bot
    //             data_temp[2] == 96;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);

    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 0;

    //             //left
    //             data_temp[1] == 79;

    //             //bot
    //             data_temp[2] == 0;

    //             //top
    //             data_temp[3] == 133;
    //             })

    // get_response(rsp);



    // `uvm_do_with(req,
    //             {
    //             // right
    //             data_temp[0] == 45;

    //             //left
    //             data_temp[1] == 0;

    //             //bot
    //             data_temp[2] == 28;

    //             //top
    //             data_temp[3] == 0;
    //             })

    // get_response(rsp);
    // repeat (10) begin
    //   `uvm_do_with(req, {

    //   })
    //   get_response(req); 
    // end
    repeat (76800) begin // 45 cells * 64 pixels
      `uvm_do_with(req,
                   {
                      // req.data_temp[0] == 0;
                      // req.data_temp[1] == 0;
                      // req.data_temp[2] == 0;
                      // req.data_temp[3] == 0;
                   }) 
      // cnt_2 = cnt_2 + 1;
      // if (cnt_2 % 64 == 0) cnt = cnt + 3;
      // if (cnt == 255) begin
      //   cnt = 0;
      // end
      get_response(rsp);
    end
  endtask
endclass