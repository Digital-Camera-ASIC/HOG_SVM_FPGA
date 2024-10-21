class init_read_seq extends uvm_sequence #(base_item);
    base_item req;
    `uvm_object_utils_begin(init_read_seq)
        `uvm_field_object(req, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "init_read_seq");
        super.new(name);
    endfunction : new
  
    virtual task body();
        repeat(1200) begin
            `uvm_do(req)
            get_response(rsp);
        end
    endtask
endclass
