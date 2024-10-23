class base_test extends uvm_test;

  `uvm_component_utils(base_test)
  base_env bus_env;
  init_read_seq seq0;
  bit test_pass;

  // The test's constructor
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Update this component's properties and create the base_tb component.
  virtual function void build_phase(uvm_phase phase); // Create the testbench.
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "*", "test_phase", 1);
    bus_env = base_env::type_id::create("bus_env", this);
    uvm_config_db#(int)::set(this,"bus_env.master", "is_active", UVM_ACTIVE);
  endfunction

  virtual function void end_of_elaboration();
    uvm_top.print_topology();
  endfunction : end_of_elaboration
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq0 = init_read_seq::type_id::create("sequence0");
    seq0.start(bus_env.master.sequencer);
    #14ns; // 8ns
    phase.drop_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    int error_cnt;
    uvm_report_server server;

    server = get_report_server();
    error_cnt = server.get_severity_count(UVM_FATAL) +
                server.get_severity_count(UVM_ERROR);

    if(error_cnt == 0) begin
      test_pass = 1;
    end
    
    //`uvm_info(get_type_name(), $sformatf("Coverage percentage: %f%%", bus_env.master.monitor.cov_trans.get_coverage()), UVM_LOW)

    if(test_pass) begin
      `uvm_info(get_type_name(), "** TEST PASSED **", UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "** TEST FAIL **")
    end
  endfunction
endclass
