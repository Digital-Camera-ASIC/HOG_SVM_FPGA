`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)
`include "../coef_container.sv"

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  logic [287 : 0] drv_fea_a[29][39];
  logic [287 : 0] drv_fea_b[29][39];
  logic [287 : 0] drv_fea_c[29][39];
  logic [287 : 0] drv_fea_d[29][39];

  logic [287 : 0] fea_a_cal[15][7];
  logic [287 : 0] fea_b_cal[15][7];
  logic [287 : 0] fea_c_cal[15][7];
  logic [287 : 0] fea_d_cal[15][7];

  logic [287 : 0] coef_a_cal[15][7];
  logic [287 : 0] coef_b_cal[15][7];
  logic [287 : 0] coef_c_cal[15][7];
  logic [287 : 0] coef_d_cal[15][7];

  logic [287:0] coef_temp [420];

  int row;
  int col;
  real sum;
  int count = 0;

  real temp_fea_a[15][7][9];
  real temp_fea_b[15][7][9];
  real temp_fea_c[15][7][9];
  real temp_fea_d[15][7][9];

  real temp_coef_a[15][7][9];
  real temp_coef_b[15][7][9];
  real temp_coef_c[15][7][9];
  real temp_coef_d[15][7][9];

  real golden_result[$];
  real mon_result[$];
  string coef_name;
  real temp_result_mon;
  int cnt_compare = 0;
  // coef_container coef_db;

  logic [287:0] test_coef[420];

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv_item_collected_export = new("drv_item_collected_export", this);
    mon_item_collected_export = new("mon_item_collected_export", this);

    for (int i = 0; i < 420; i++) begin
      coef_name = {"coef_", $sformatf("%0d", i)};
      if (!uvm_config_db#(logic [287:0])::get(this, "*", coef_name, test_coef[i])) begin
          `uvm_fatal("no coef", {"IN: ", get_type_name()})
      end
    end
    for (int i = 0; i < 420; i++) begin
      $display("test_coef[%d]: %h", i, test_coef[i]);
    end

    row = 0;
    col = 0;

    for (int i = 0; i < 420; i = i + 4) begin
      coef_a_cal[row][col % 7] = test_coef[i];
      coef_b_cal[row][col % 7] = test_coef[i + 1];
      coef_c_cal[row][col % 7] = test_coef[i + 2];
      coef_d_cal[row][col % 7] = test_coef[i + 3];
      col ++;
      if (col % 7 == 0) row ++;
    end

    for (int i = 0; i < 15; i ++) begin
      for (int j = 0; j < 7; j ++) begin
        for (int k = 0; k < 9; k ++) begin
          if (coef_a_cal[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_coef_a[i][j][k] = -1.0*(~coef_a_cal[i][j][k*32+:32] + 1'b1)/2**28;
          end
          else begin
            temp_coef_a[i][j][k]= (1.0 * (coef_a_cal[i][j][k*32+:32]) / 2 ** 28);
          end
    
          if (coef_b_cal[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_coef_b[i][j][k] = -1.0*(~coef_b_cal[i][j][k*32+:32] + 1'b1)/2**28;
          end
          else begin
            temp_coef_b[i][j][k]= (1.0 * (coef_b_cal[i][j][k*32+:32]) / 2 ** 28);
          end
    
          if (coef_c_cal[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_coef_c[i][j][k] = -1.0*(~coef_c_cal[i][j][k*32+:32] + 1'b1)/2**28;
          end
          else begin
            temp_coef_c[i][j][k]= (1.0 * (coef_c_cal[i][j][k*32+:32]) / 2 ** 28);
          end
    
          if (coef_d_cal[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_coef_d[i][j][k] = -1.0*(~coef_d_cal[i][j][k*32+:32] + 1'b1)/2**28;
          end
          else begin
            temp_coef_d[i][j][k]= (1.0 * (coef_d_cal[i][j][k*32+:32]) / 2 ** 28);
          end
        end
      end
    end

    for (int i = 0; i < 15; i ++) begin
      for (int j = 0; j < 7; j ++) begin
        for (int k = 0; k < 9; k ++) begin
          $display("temp_coef_a[%0d]: %f, temp_coef_b[%0d]: %f, temp_coef_c[%0d]: %f, temp_coef_d[%0d]: %f", k, temp_coef_a[i][j][k], k, temp_coef_b[i][j][k], k, temp_coef_c[i][j][k], k, temp_coef_d[i][j][k]);
        end
      end
    end
    for (int i = 0; i < 15; i ++) begin
      for (int j = 0; j < 7; j ++) begin
        for (int k = 0; k < 9; k ++) begin
          temp_fea_a[i][j][k] = 0;
          temp_fea_b[i][j][k] = 0;
          temp_fea_c[i][j][k] = 0;
          temp_fea_d[i][j][k] = 0;
        end
      end
    end
    row = 0;
    col = 0;
  endfunction

  function void extract_feature(logic [287:0] fea_a[15][7], logic [287:0] fea_b[15][7], logic [287:0] fea_c[15][7], logic [287:0] fea_d[15][7]);
    sum = 0;
    for (int i = 0; i < 15; i ++) begin
      for (int j = 0; j < 7; j ++) begin
        for (int k = 0; k < 9; k ++) begin
          if (fea_a[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_fea_a[i][j][k] = -1.0 * (~fea_a[i][j][k*32+:32] + 1'b1) / 2 ** 28;
          end
          else begin
            temp_fea_a[i][j][k] = 1.0 * fea_a[i][j][k*32+:32] / 2 ** 28;
          end
    
          if (fea_b[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_fea_b[i][j][k] = -1.0 * (~fea_b[i][j][k*32+:32] + 1'b1) / 2 ** 28;
          end
          else begin
            temp_fea_b[i][j][k] = 1.0 * fea_b[i][j][k*32+:32] / 2 ** 28;
          end
    
          if (fea_c[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_fea_c[i][j][k] = -1.0 * (~fea_c[i][j][k*32+:32] + 1'b1) / 2 ** 28;
          end
          else begin
            temp_fea_c[i][j][k] = 1.0 * fea_c[i][j][k*32+:32] / 2 ** 28;
          end
    
          if (fea_d[i][j][(k+1) * 32 - 1] == 1'b1) begin  
            temp_fea_d[i][j][k] = -1.0 * (~fea_d[i][j][k*32+:32] + 1'b1) / 2 ** 28;
          end
          else begin
            temp_fea_d[i][j][k] = 1.0 * fea_d[i][j][k*32+:32] / 2 ** 28;
          end
        end
      end
    end


    // for (int i = 0; i < 9; i++) begin
    //   $display("temp_fea_a[%0d]: %f, temp_fea_b[%0d]: %f, temp_fea_c[%0d]: %f, temp_fea_d[%0d]: %f", i, temp_fea_a[i], i, temp_fea_b[i], i, temp_fea_c[i], i, temp_fea_d[i]);
    //   $display("temp_coef_a[%0d]: %f, temp_coef_b[%0d]: %f, temp_coef_c[%0d]: %f, temp_coef_d[%0d]: %f", i, temp_coef_a[i], i, temp_coef_b[i], i, temp_coef_c[i], i, temp_coef_d[i]);
    // end

    for (int i = 0; i < 15; i ++) begin
      for (int j = 0; j < 7; j ++) begin
        for (int k = 0; k < 9; k ++) begin
          sum = sum + 1.0 * temp_fea_a[i][j][k] * temp_coef_a[i][j][k];
          sum = sum + 1.0 * temp_fea_b[i][j][k] * temp_coef_b[i][j][k];
          sum = sum + 1.0 * temp_fea_c[i][j][k] * temp_coef_c[i][j][k];
          sum = sum + 1.0 * temp_fea_d[i][j][k] * temp_coef_d[i][j][k];
        end
      end
    end

    $display("golden_result: %f", sum);
    golden_result.push_back(sum);
  endfunction

  virtual function void write_drv(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)
    drv_fea_a[row][col % 39] = item.fea_a;
    drv_fea_b[row][col % 39] = item.fea_b;
    drv_fea_c[row][col % 39] = item.fea_c;
    drv_fea_d[row][col % 39] = item.fea_d;
    for (int i = 0; i <= row; i++) begin
      for (int j = 0; j <= col % 39; j ++) begin
        $display("DRV: ROW: %d, COL: %d, drv_fea: %h", i, j, drv_fea_a[i][j]);
      end
    end
    // $display("DRV: ROW: %d, COL: %d", row, col % 39);
    if (col % 39 >= 6 && row >= 14) begin
      $display("Enter frame num: %d", count);
      count ++;
      for (int i = 0; i < 15; i++) begin
        for (int j = 0; j < 7; j++) begin
          fea_a_cal[i][j] = drv_fea_a[i + row - 14][j + col % 39 - 6];
          fea_b_cal[i][j] = drv_fea_b[i + row - 14][j + col % 39 - 6];
          fea_c_cal[i][j] = drv_fea_c[i + row - 14][j + col % 39 - 6];
          fea_d_cal[i][j] = drv_fea_d[i + row - 14][j + col % 39 - 6];
          $display("ROW: %d, COL: %d", i + row - 14, j + col % 39 - 6);
        end
      end
      extract_feature(fea_a_cal, fea_b_cal, fea_c_cal, fea_d_cal);
    end

    col ++;
    if (col % 39 == 0) row ++;

  endfunction

  virtual function void write_mon(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    if (item.result[31] == 1'b1) begin  
        temp_result_mon = -1.0*(~item.result + 1'b1)/2**28;
      end
    else begin
      temp_result_mon= (1.0 * item.result / 2 ** 28);
    end

    $display("result mon: %f", temp_result_mon);
    mon_result.push_back(temp_result_mon);
  endfunction

  virtual function void extract_phase(uvm_phase phase);
    // while (mon_result.size() > 0) begin
    //   $display ("mon_result[%d]: %f", cnt_compare ,mon_result[0]);
    //   mon_result.pop_front();
    //   cnt_compare ++;
    // end
    // cnt_compare = 0;
    // while (golden_result.size() > 0) begin
    //   $display ("golden_result[%d]: %f", cnt_compare, golden_result[0]);
    //   golden_result.pop_front();
    //   cnt_compare ++;
    // end
    cnt_compare = 0;
    while (mon_result.size() > 0 && golden_result.size() > 0) begin
      $display(cnt_compare);
      if ((mon_result[0] - golden_result[0]) > 1e-6 || (mon_result[0] - golden_result[0]) < -1e-6) begin
        `uvm_error(get_type_name(), "Result is not match")
        `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", golden_result[0], mon_result[0]), UVM_LOW)
      end
      else begin
        `uvm_info(get_type_name(), "Result PASS", UVM_LOW)
      end
      cnt_compare ++;
      mon_result.pop_front();
      golden_result.pop_front();
    end




  //   $display("Tinh toan %f", $sqrt(40 * 1.0 / (40 + 41 + 80 + 81)));
  //   `uvm_info(get_type_name(), "Extract phase", UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_a_golden size: %0d", q_fea_a_golden.size()),
  //             UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_b_golden size: %0d", q_fea_b_golden.size()),
  //             UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_c_golden size: %0d", q_fea_c_golden.size()),
  //             UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_d_golden size: %0d", q_fea_d_golden.size()),
  //             UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_a size: %0d", q_fea_a.size()), UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_b size: %0d", q_fea_b.size()), UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_c size: %0d", q_fea_c.size()), UVM_LOW)
  //   `uvm_info(get_type_name(), $sformatf("q_fea_d size: %0d", q_fea_d.size()), UVM_LOW)

  //   while (q_fea_a_golden.size() > 0 && q_fea_a.size() > 0) begin
  //     cnt_compare = cnt_compare + 1;
  //     $display($sformatf("Compare %0d", cnt_compare));
  //     for (int i = 0; i < 9; i++) begin
  //       if ((q_fea_a_golden[0][i] - q_fea_a[0][i]) > 1e-6 || (q_fea_a_golden[0][i] - q_fea_a[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature a[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_a_golden[0][i],
  //                                              q_fea_a[0][i]), UVM_LOW)
  //       end
  //       else begin
  //         `uvm_info(get_type_name(), $sformatf("Feature a[%0d] PASS", i), UVM_LOW)
  //       end
  //       if ((q_fea_b_golden[0][i] - q_fea_b[0][i]) > 1e-6 || (q_fea_b_golden[0][i] - q_fea_b[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature b[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_b_golden[0][i],
  //                                              q_fea_b[0][i]), UVM_LOW)
  //       end
  //       else begin
  //         `uvm_info(get_type_name(), $sformatf("Feature b[%0d] PASS", i), UVM_LOW)
  //       end
  //       if ((q_fea_c_golden[0][i] - q_fea_c[0][i]) > 1e-6 || (q_fea_c_golden[0][i] - q_fea_c[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature c[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_c_golden[0][i],
  //                                              q_fea_c[0][i]), UVM_LOW)
  //       end
  //       else begin
  //         `uvm_info(get_type_name(), $sformatf("Feature c[%0d] PASS", i), UVM_LOW)
  //       end
  //       if ((q_fea_d_golden[0][i] - q_fea_d[0][i]) > 1e-6 || (q_fea_d_golden[0][i] - q_fea_d[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature d[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_d_golden[0][i],
  //                                              q_fea_d[0][i]), UVM_LOW)
  //       end
  //       else begin
  //         `uvm_info(get_type_name(), $sformatf("Feature d[%0d] PASS", i), UVM_LOW)
  //       end
  //     end
  //     q_fea_a.pop_front();
  //     q_fea_b.pop_front();
  //     q_fea_c.pop_front();
  //     q_fea_d.pop_front();
  //     q_fea_a_golden.pop_front();
  //     q_fea_b_golden.pop_front();
  //     q_fea_c_golden.pop_front();
  //     q_fea_d_golden.pop_front();
    // end



    // TEST 




  endfunction


endclass
