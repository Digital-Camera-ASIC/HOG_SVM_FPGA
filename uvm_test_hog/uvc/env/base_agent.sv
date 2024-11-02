class base_agent extends uvm_agent;
  uvm_active_passive_enum is_active;
  `uvm_component_utils_begin(base_agent)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end
  base_monitor monitor;
  uvm_sequencer #(base_item) sequencer;
  base_driver driver;

  function new(string name = "base_agent", uvm_component parent);
      super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (is_active == UVM_ACTIVE) begin
          sequencer = uvm_sequencer #(base_item)::type_id::create("sequencer", this);
          driver = base_driver::type_id::create("driver", this);
      end
      monitor = base_monitor::type_id::create("monitor", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
      if (is_active == UVM_ACTIVE) begin
          driver.seq_item_port.connect(sequencer.seq_item_export);
      end
  endfunction

  task run_phase(uvm_phase phase);
      // if (is_active == UVM_ACTIVE) begin
      //     driver.run_phase(phase);
      // end
  endtask
endclass : base_agent