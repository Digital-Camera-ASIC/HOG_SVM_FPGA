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
        repeat(200) begin
            `uvm_do_with(req, {
                req.addr == cnt;
                foreach (req.r_bin[i]) {
                    if (i == 0) {
                        req.r_bin[i] == cnt;
                    } else {
                    req.r_bin[i] == 0;
                    }
                }
            })

            cnt++;
            // `uvm_do(req);
            get_response(rsp);
        end
    endtask
endclass
