class base_monitor extends uvm_monitor;
  virtual dut_if vif;
  bit checks_enable = 1;
  bit coverage_enable = 1;
  uvm_analysis_port #(base_item) item_collected_port;
  `uvm_component_utils_begin(base_monitor)
    `uvm_field_int(checks_enable, UVM_ALL_ON)
    `uvm_field_int(coverage_enable, UVM_ALL_ON)
  `uvm_component_utils_end
  protected base_item trans_collected;
  protected base_item temp_trans;
  event cov_transaction;
  int test_phase;
  int i;
  covergroup cov_trans @cov_transaction;
  // coverpoint
  endgroup : cov_trans


  function new(string name = "base_monitor", uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
    trans_collected = new();
    cov_trans = new();
    cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name()})
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @vif.cb;
      if (vif.cb.o_valid) begin
        trans_collected.is_person = vif.cb.is_person;
        trans_collected.led = vif.cb.led;
        trans_collected.sw_id = vif.cb.sw_id;
        trans_collected.o_valid = vif.cb.o_valid;
        $cast(temp_trans, trans_collected.clone());
        temp_trans.set_id_info(trans_collected);
        item_collected_port.write(temp_trans);
      end
    end
  endtask



  virtual protected function void perform_transfer_coverage();
    // -> cov_transaction;
  endfunction

  virtual protected function void perform_transfer_checks();


  endfunction

endclass
