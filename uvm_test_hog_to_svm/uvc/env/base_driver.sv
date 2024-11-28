class base_driver extends uvm_driver #(base_item);

  uvm_analysis_port #(base_item) item_collected_port;
  `uvm_component_utils(base_driver)
  virtual dut_if vif;
  base_item b_item;
  int cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    b_item = new();
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cnt = 0;
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(b_item);
      `uvm_info("run_phase", $sformatf("Start driver: %s", b_item.sprint()), UVM_LOW)
      $cast(rsp, b_item.clone());
      rsp.set_id_info(b_item);
      drive_item(rsp);
      seq_item_port.item_done(rsp);
      item_collected_port.write(rsp);
    end
  endtask

  task drive_item(base_item item);
    wait (vif.rst);
    wait (vif.request);
    @vif.cb;
    vif.cb.i_data <= item.data;
    // `uvm_info("DEBUG-DRIVER", $sformatf("data: %h", item.data), UVM_LOW)
    vif.cb.ready <= 1;
    
    cnt++;

    if (cnt == 1200) begin
      repeat(5) begin
        @vif.cb;
        vif.cb.ready <= 0;
      end
      cnt = 0;
    end
  endtask

endclass : base_driver
