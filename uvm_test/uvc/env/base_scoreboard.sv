`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  logic [287:0] [42] fifo;

  logic [287:0] bin_1;
  logic [287:0] bin_2;
  logic [287:0] bin_3;
  logic [287:0] bin_4;

  logic [287:0] fea_a;
  logic [287:0] fea_b;
  logic [287:0] fea_c;
  logic [287:0] fea_d;

  int cnt;

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction


    function void build_phase(uvm_phase phase);
      drv_item_collected_export = new("drv_item_collected_export", this);
      mon_item_collected_export = new("mon_item_collected_export", this);
      cnt = 0;
      for (int i = 0; i < 42; i++) begin
        fifo[i] = 0;
      end
    endfunction

    virtual function void write_drv (base_item item);
      `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)
      for (int j = 41; j > 0; j--) begin
        fifo[j] <= fifo[j - 1];
      end
      fifo[0] = item.r_bin;
      cnt = cnt + 1;
      if (cnt == 42) begin
        // Tinh toan feature de so sanh
        `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
        bin_1 = fifo[41];
        bin_2 = fifo[40];
        bin_3 = fifo[1];
        bin_4 = fifo[0];

      
        cnt = cnt - 1;
      end
    endfunction

    virtual function void write_mon (base_item item);
      `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    endfunction
            
            
            
  endclass