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
    @vif.cb;
    // if (cnt == 20) vif.cb.i_valid <= 0;
    // else vif.cb.i_valid <= 1;
    vif.cb.i_valid <= item.i_valid;
    // item.i_valid = vif.cb.i_valid;
    // vif.cb.addr_fw <= 1;
    if (cnt >= 100) vif.cb.addr_fw <= 2;
    else vif.cb.addr_fw <= 1;
    item.addr_fw = vif.cb.addr_fw;
    vif.cb.addr <= item.addr;
    vif.cb.bin <= {
      item.r_bin[8],
      item.r_bin[7],
      item.r_bin[6],
      item.r_bin[5],
      item.r_bin[4],
      item.r_bin[3],
      item.r_bin[2],
      item.r_bin[1],
      item.r_bin[0]
    };
    // vif.cb.bin <= cnt;
    // item.addr = cnt;
    cnt++;
  endtask

endclass : base_driver
