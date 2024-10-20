`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  logic [42] [287:0] fifo;

  logic [287:0] bin_1;
  logic [287:0] bin_2;
  logic [287:0] bin_3;
  logic [287:0] bin_4;

  real temp_fea_a[9];
  real temp_fea_b[9];
  real temp_fea_c[9];
  real temp_fea_d[9];

  real q_fea_a [$][9];
  real q_fea_b [$][9];
  real q_fea_c [$][9];
  real q_fea_d [$][9];

  real temp;
  real sum;
  int cnt;
  int k;

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void extract_feature (logic [287:0] bin_1, logic [287:0] bin_2, logic [287:0] bin_3, logic [287:0] bin_4);
    sum = 0;
    for (int i = 0; i < 288; i = i + 32) begin
      k = i;
      sum = sum + 1.0*(bin_1[i +: 32]) / 2**16;
      sum = sum + 1.0*(bin_2[i +: 32]) / 2**16;
      sum = sum + 1.0*(bin_3[i +: 32]) / 2**16;
      sum = sum + 1.0*(bin_4[i +: 32]) / 2**16;
    end
    for (int i = 0; i < 288; i = i + 32) begin
      temp_fea_a[i/32] = $sqrt( (1.0*(bin_1[i +: 32]) / 2**16) / sum );
      temp_fea_b[i/32] = $sqrt( (1.0*(bin_2[i +: 32]) / 2**16) / sum );
      temp_fea_c[i/32] = $sqrt( (1.0*(bin_3[i +: 32]) / 2**16) / sum );
      temp_fea_d[i/32] = $sqrt( (1.0*(bin_4[i +: 32]) / 2**16) / sum );
    end
    q_fea_a.push_back(temp_fea_a);
    q_fea_b.push_back(temp_fea_b);
    q_fea_c.push_back(temp_fea_c);
    q_fea_d.push_back(temp_fea_d);
    $display($sformatf("--------------------"));

    $display($sformatf("Bin_1: %h, Bin_2: %h, Bin_3: %h, Bin_4: %h", bin_1, bin_2, bin_3, bin_4));

    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature a[%0d]: %f", i, temp_fea_a[i]));
      $display($sformatf("feature b[%0d]: %f", i, temp_fea_b[i]));
      $display($sformatf("feature c[%0d]: %f", i, temp_fea_c[i]));
      $display($sformatf("feature d[%0d]: %f", i, temp_fea_d[i]));
    end

    $display($sformatf("--------------------"));
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
        fifo[j] = fifo[j - 1];
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
        extract_feature(bin_1, bin_2, bin_3, bin_4);
        cnt = cnt - 1;
      end
      for (int i = 0; i < cnt; i++) begin
        $display($sformatf("FIFO[%0d]: %h", i, fifo[i]));
      end
    endfunction

    virtual function void write_mon (base_item item);
      `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    endfunction
            
            
            
  endclass