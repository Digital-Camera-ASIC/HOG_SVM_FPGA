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
    // forever begin
    //         if(!uvm_config_db #(int)::get(this, "", "test_phase", test_phase))
    //             `uvm_fatal("NO_TEST_PHASE", {"IN :", get_type_name()})
    // //        if (test_phase == 4) begin
    //             if (coverage_enable) perform_transfer_coverage();
    //             if (checks_enable) perform_transfer_checks();
    //     //    end
    //   @(posedge vif.apb_clk);
    //        if (vif.apb_enable == 1 && vif.apb_ready == 1 && vif.apb_sel == 1) begin
    //          trans_collected.apb_addr  = vif.apb_addr;
    //          trans_collected.apb_write = vif.apb_write;
    //                 trans_collected.apb_rdata = vif.apb_rdata;
    //                 trans_collected.apb_wdata = vif.apb_wdata;
    //                 trans_collected.apb_strb = vif.apb_strb;
    //                 trans_collected.apb_slverr = vif.apb_slverr;
    //                 $cast(temp_trans, trans_collected.clone());
    //                 temp_trans.set_id_info(trans_collected);
    //                 item_collected_port.write(temp_trans);
    //           end
    //             if (vif.apb_slverr == 1) begin
    //                 if(vif.apb_write == 0) `uvm_warning($sformatf("Slave error in phase %0d", test_phase), $sformatf("Read unsuccessfully at Addr: %h",vif.apb_addr))
    //                 else `uvm_warning($sformatf("Slave error in phase %0d", test_phase), $sformatf("Write unsuccessfully at Addr: %h",vif.apb_addr))
    //   end
    //         end
    forever begin
      @vif.cb;
      if (vif.cb.o_valid) begin
        trans_collected.fea_a = vif.cb.fea_a;
        trans_collected.fea_b = vif.cb.fea_b;
        trans_collected.fea_c = vif.cb.fea_c;
        trans_collected.fea_d = vif.cb.fea_d;
        trans_collected.bid = vif.cb.bid;
        trans_collected.o_valid = vif.o_valid;
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
