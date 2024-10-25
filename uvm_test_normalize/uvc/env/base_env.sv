class base_env extends uvm_env;
  
  base_agent master;
  base_scoreboard scoreboard0;

  `uvm_component_utils(base_env)

  function new(string name = "base_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    master = base_agent::type_id::create("master", this);
    scoreboard0 = base_scoreboard::type_id::create("scoreboard0", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    master.monitor.item_collected_port.connect(scoreboard0.mon_item_collected_export);
    master.driver.item_collected_port.connect(scoreboard0.drv_item_collected_export);
  endfunction

  virtual function void end_of_elaboration();

  endfunction
endclass