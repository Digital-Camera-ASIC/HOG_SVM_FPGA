`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  logic [42][287:0] fifo;

  logic [287:0] bin_1;
  logic [287:0] bin_2;
  logic [287:0] bin_3;
  logic [287:0] bin_4;

  real temp_fea_a[9];
  real temp_fea_b[9];
  real temp_fea_c[9];
  real temp_fea_d[9];

  real q_fea_a_golden[$][9];
  real q_fea_b_golden[$][9];
  real q_fea_c_golden[$][9];
  real q_fea_d_golden[$][9];

  real q_fea_a[$][9];
  real q_fea_b[$][9];
  real q_fea_c[$][9];
  real q_fea_d[$][9];

  real temp;
  real sum;
  int cnt;
  int cnt_compare;
  int cnt_debug = 0;
  int now_addr_fw;

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void extract_feature(logic [287:0] bin_1, logic [287:0] bin_2, logic [287:0] bin_3,
                                logic [287:0] bin_4);
    sum = 0;
    for (int i = 0; i < 288; i = i + 32) begin
      sum = sum + 1.0 * (bin_1[i+:32]) / 2 ** 16;
      sum = sum + 1.0 * (bin_2[i+:32]) / 2 ** 16;
      sum = sum + 1.0 * (bin_3[i+:32]) / 2 ** 16;
      sum = sum + 1.0 * (bin_4[i+:32]) / 2 ** 16;
    end
    $display("index: %0d", cnt_debug++);
    $display("Sum : %f", sum);
    for (int i = 0; i < 288; i = i + 32) begin
      temp_fea_a[i/32] = $sqrt((1.0 * (bin_1[i+:32]) / 2 ** 16) / sum);
      temp_fea_b[i/32] = $sqrt((1.0 * (bin_2[i+:32]) / 2 ** 16) / sum);
      temp_fea_c[i/32] = $sqrt((1.0 * (bin_3[i+:32]) / 2 ** 16) / sum);
      temp_fea_d[i/32] = $sqrt((1.0 * (bin_4[i+:32]) / 2 ** 16) / sum);
    end
    q_fea_a_golden.push_back(temp_fea_a);
    q_fea_b_golden.push_back(temp_fea_b);
    q_fea_c_golden.push_back(temp_fea_c);
    q_fea_d_golden.push_back(temp_fea_d);
    $display($sformatf("--------------------"));

    $display($sformatf("Bin_1: %h, Bin_2: %h, Bin_3: %h, Bin_4: %h", bin_1, bin_2, bin_3, bin_4));

    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature a[%0d]: %f", i, temp_fea_a[i]));
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature b[%0d]: %f", i, temp_fea_b[i]));
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature c[%0d]: %f", i, temp_fea_c[i]));
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature d[%0d]: %f", i, temp_fea_d[i]));
    end

    $display($sformatf("--------------------"));
  endfunction

  function void reset_for_new_frame();
    cnt = 0;
    cnt_compare = 0;
    now_addr_fw = 0;
    for (int i = 0; i < 42; i++) begin
      fifo[i] = 0;
    end
  endfunction

  function void build_phase(uvm_phase phase);
    drv_item_collected_export = new("drv_item_collected_export", this);
    mon_item_collected_export = new("mon_item_collected_export", this);
    cnt = 0;
    cnt_compare = 0;
    now_addr_fw = 0;
    for (int i = 0; i < 42; i++) begin
      fifo[i] = 0;
    end
  endfunction


  virtual function void write_drv(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)
    if (item.addr_fw != now_addr_fw) begin
      now_addr_fw = item.addr_fw;
      reset_for_new_frame();
    end
    if (item.i_valid == 1) begin
      for (int j = 41; j > 0; j--) begin
        fifo[j] = fifo[j-1];
      end
      fifo[0] = item.r_bin;
      cnt = cnt + 1;
      $display($sformatf("cnt = %0d", cnt));
      for (int i = 0; i < cnt; i++) begin
        $display($sformatf("FIFO[%0d]: %h", i, fifo[i]));
      end
      if (cnt == 42) begin
        // Tinh toan feature de so sanh
        if (item.addr % 40 != 0) begin
          `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
          bin_1 = fifo[41];
          bin_2 = fifo[40];
          bin_3 = fifo[1];
          bin_4 = fifo[0];
          extract_feature(bin_1, bin_2, bin_3, bin_4);
        end
        cnt = cnt - 1;
      end
    end
  endfunction

  virtual function void write_mon(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    for (int i = 0; i < 288; i = i + 32) begin
      temp_fea_a[i/32] = 1.0 * (item.fea_a[i+:32]) / 2 ** 28;  //1.0*(bin_1[i +: 32]) / 2**16
      temp_fea_b[i/32] = 1.0 * (item.fea_b[i+:32]) / 2 ** 28;
      temp_fea_c[i/32] = 1.0 * (item.fea_c[i+:32]) / 2 ** 28;
      temp_fea_d[i/32] = 1.0 * (item.fea_d[i+:32]) / 2 ** 28;
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature a[%0d]: %f", i, temp_fea_a[i]));
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature b[%0d]: %f", i, temp_fea_b[i]));
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature c[%0d]: %f", i, temp_fea_c[i]));
    end
    for (int i = 0; i < 9; i++) begin
      $display($sformatf("feature d[%0d]: %f", i, temp_fea_d[i]));
    end
    q_fea_a.push_back(temp_fea_a);
    q_fea_b.push_back(temp_fea_b);
    q_fea_c.push_back(temp_fea_c);
    q_fea_d.push_back(temp_fea_d);
  endfunction

  virtual function void extract_phase(uvm_phase phase);
    $display("Tinh toan %f", $sqrt(40 * 1.0 / (40 + 41 + 80 + 81)));
    `uvm_info(get_type_name(), "Extract phase", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_a_golden size: %0d", q_fea_a_golden.size()),
              UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_b_golden size: %0d", q_fea_b_golden.size()),
              UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_c_golden size: %0d", q_fea_c_golden.size()),
              UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_d_golden size: %0d", q_fea_d_golden.size()),
              UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_a size: %0d", q_fea_a.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_b size: %0d", q_fea_b.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_c size: %0d", q_fea_c.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("q_fea_d size: %0d", q_fea_d.size()), UVM_LOW)

    while (q_fea_a_golden.size() > 0 && q_fea_a.size() > 0) begin
      cnt_compare = cnt_compare + 1;
      $display($sformatf("Compare %0d", cnt_compare));
      for (int i = 0; i < 9; i++) begin
        if ((q_fea_a_golden[0][i] - q_fea_a[0][i]) > 1e-6 || (q_fea_a_golden[0][i] - q_fea_a[0][i]) < -1e-6) begin
          `uvm_error(get_type_name(), $sformatf("Feature a[%0d] is not match", i))
          `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_a_golden[0][i],
                                               q_fea_a[0][i]), UVM_LOW)
        end
        if ((q_fea_b_golden[0][i] - q_fea_b[0][i]) > 1e-6 || (q_fea_b_golden[0][i] - q_fea_b[0][i]) < -1e-6) begin
          `uvm_error(get_type_name(), $sformatf("Feature b[%0d] is not match", i))
          `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_b_golden[0][i],
                                               q_fea_b[0][i]), UVM_LOW)
        end
        if ((q_fea_c_golden[0][i] - q_fea_c[0][i]) > 1e-6 || (q_fea_c_golden[0][i] - q_fea_c[0][i]) < -1e-6) begin
          `uvm_error(get_type_name(), $sformatf("Feature c[%0d] is not match", i))
          `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_c_golden[0][i],
                                               q_fea_c[0][i]), UVM_LOW)
        end
        if ((q_fea_d_golden[0][i] - q_fea_d[0][i]) > 1e-6 || (q_fea_d_golden[0][i] - q_fea_d[0][i]) < -1e-6) begin
          `uvm_error(get_type_name(), $sformatf("Feature d[%0d] is not match", i))
          `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_d_golden[0][i],
                                               q_fea_d[0][i]), UVM_LOW)
        end
      end
      q_fea_a.pop_front();
      q_fea_b.pop_front();
      q_fea_c.pop_front();
      q_fea_d.pop_front();
      q_fea_a_golden.pop_front();
      q_fea_b_golden.pop_front();
      q_fea_c_golden.pop_front();
      q_fea_d_golden.pop_front();
    end
  endfunction


endclass
