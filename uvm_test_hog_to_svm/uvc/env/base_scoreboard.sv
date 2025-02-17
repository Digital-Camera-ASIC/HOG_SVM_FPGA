`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  `define DEBUG 1

  parameter real pi = 3.141592653589793;
  parameter real epsilon = 0.0001;

  parameter int frac_part = 16;
  parameter int int_part = 4;

  logic [42][767:0] fifo;

  logic [767:0] data_1;
  logic [767:0] data_2;
  logic [767:0] data_3;
  logic [767:0] data_4;

  real Gx_1[64];
  real Gx_2[64];
  real Gx_3[64];
  real Gx_4[64];

  real Gy_1[64];
  real Gy_2[64];
  real Gy_3[64];
  real Gy_4[64];

  real Magnitude_1[64];
  real Magnitude_2[64];
  real Magnitude_3[64];
  real Magnitude_4[64];

  real Orientation_1[64];
  real Orientation_2[64];
  real Orientation_3[64];
  real Orientation_4[64];

  real bin_1[9];
  real bin_2[9];
  real bin_3[9];
  real bin_4[9];


  real temp_fea_a[9];
  real temp_fea_b[9];
  real temp_fea_c[9];
  real temp_fea_d[9];

  real temp;
  real sum;
  int cnt;
  int cnt_compare;
  int cnt_debug = 0;
  int cnt_addr = 0;



  // NEW PARAMETER
  real golden_result[$];
  real mon_result[$];

  string coef_name;
  logic [9 * (int_part + frac_part) - 1:0] test_coef[420];
  logic [9 * (int_part + frac_part) - 1:0] coef_temp [420];

  real temp_result_mon;

  real temp_coef_a[15][7][9];
  real temp_coef_b[15][7][9];
  real temp_coef_c[15][7][9];
  real temp_coef_d[15][7][9];

  int row = 0;
  int col = 0;

  real fea_a_cal[15][7][9];
  real fea_b_cal[15][7][9];
  real fea_c_cal[15][7][9];
  real fea_d_cal[15][7][9];

  logic [287 : 0] coef_a_cal[15][7];
  logic [287 : 0] coef_b_cal[15][7];
  logic [287 : 0] coef_c_cal[15][7];
  logic [287 : 0] coef_d_cal[15][7];

  real drv_fea_a[29][39][9];
  real drv_fea_b[29][39][9];
  real drv_fea_c[29][39][9];
  real drv_fea_d[29][39][9];

  real sum_svm;

  function real abs(real a);
    if (a < 0) begin
      return -a;
    end
    else begin
      return a;
    end
  endfunction

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void extract_feature(logic [767:0] data_1, logic [767:0] data_2, logic [767:0] data_3,
                                logic [767:0] data_4);

    for (int i = 0; i < 8; i++) begin
      Gx_1[i*8] = 1.0 * data_1[(i*8 + 1)*8+:8] - 1.0 * data_1[(72 + i)*8+:8];
      Gx_2[i*8] = 1.0 * data_2[(i*8 + 1)*8+:8] - 1.0 * data_2[(72 + i)*8+:8];
      Gx_3[i*8] = 1.0 * data_3[(i*8 + 1)*8+:8] - 1.0 * data_3[(72 + i)*8+:8];
      Gx_4[i*8] = 1.0 * data_4[(i*8 + 1)*8+:8] - 1.0 * data_4[(72 + i)*8+:8];
    end

    for (int i = 0; i < 8; i++) begin
      Gx_1[i*8 + 7] = 1.0 * data_1[(80 + i)*8+:8] - 1.0 * data_1[(6 + i*8)*8+:8];
      Gx_2[i*8 + 7] = 1.0 * data_2[(80 + i)*8+:8] - 1.0 * data_2[(6 + i*8)*8+:8];
      Gx_3[i*8 + 7] = 1.0 * data_3[(80 + i)*8+:8] - 1.0 * data_3[(6 + i*8)*8+:8];
      Gx_4[i*8 + 7] = 1.0 * data_4[(80 + i)*8+:8] - 1.0 * data_4[(6 + i*8)*8+:8];
    end

    for (int i = 0; i < 8; i ++) begin
      for (int j = 1; j < 7; j++) begin
        Gx_1[i * 8 + j] = 1.0 * data_1[((i*8+j + 1)*8) +: 8] - 1.0 * data_1[((i*8+j - 1)*8) +: 8];
        Gx_2[i * 8 + j] = 1.0 * data_2[((i*8+j + 1)*8) +: 8] - 1.0 * data_2[((i*8+j - 1)*8) +: 8];
        Gx_3[i * 8 + j] = 1.0 * data_3[((i*8+j + 1)*8) +: 8] - 1.0 * data_3[((i*8+j - 1)*8) +: 8];
        Gx_4[i * 8 + j] = 1.0 * data_4[((i*8+j + 1)*8) +: 8] - 1.0 * data_4[((i*8+j - 1)*8) +: 8];
      end
    end

    for (int i = 0; i < 8; i++) begin
      Gy_1[i] = 1.0 * data_1[(8 + i)*8+:8] - 1.0 * data_1[(64 + i)*8+:8];
      Gy_2[i] = 1.0 * data_2[(8 + i)*8+:8] - 1.0 * data_2[(64 + i)*8+:8];
      Gy_3[i] = 1.0 * data_3[(8 + i)*8+:8] - 1.0 * data_3[(64 + i)*8+:8];
      Gy_4[i] = 1.0 * data_4[(8 + i)*8+:8] - 1.0 * data_4[(64 + i)*8+:8];
    end

    for (int i = 0; i < 8; i++) begin
      Gy_1[56 + i] = 1.0 * data_1[(88 + i)*8+:8] - 1.0 * data_1[(48 + i)*8+:8];
      Gy_2[56 + i] = 1.0 * data_2[(88 + i)*8+:8] - 1.0 * data_2[(48 + i)*8+:8];
      Gy_3[56 + i] = 1.0 * data_3[(88 + i)*8+:8] - 1.0 * data_3[(48 + i)*8+:8];
      Gy_4[56 + i] = 1.0 * data_4[(88 + i)*8+:8] - 1.0 * data_4[(48 + i)*8+:8];
    end

    for (int i = 1; i < 7; i++) begin
      for (int j = 0; j < 8; j++) begin
        Gy_1[i*8 + j] = 1.0 * data_1[((i*8 + j + 8)*8) +: 8] - 1.0 * data_1[((i*8 + j - 8)*8) +: 8];
        Gy_2[i*8 + j] = 1.0 * data_2[((i*8 + j + 8)*8) +: 8] - 1.0 * data_2[((i*8 + j - 8)*8) +: 8];
        Gy_3[i*8 + j] = 1.0 * data_3[((i*8 + j + 8)*8) +: 8] - 1.0 * data_3[((i*8 + j - 8)*8) +: 8];
        Gy_4[i*8 + j] = 1.0 * data_4[((i*8 + j + 8)*8) +: 8] - 1.0 * data_4[((i*8 + j - 8)*8) +: 8];
      end
    end

    for(int i = 0; i < 64; i++) begin
      Magnitude_1[i] = $sqrt(Gx_1[i] ** 2 + Gy_1[i] ** 2);
      Magnitude_2[i] = $sqrt(Gx_2[i] ** 2 + Gy_2[i] ** 2);
      Magnitude_3[i] = $sqrt(Gx_3[i] ** 2 + Gy_3[i] ** 2);
      Magnitude_4[i] = $sqrt(Gx_4[i] ** 2 + Gy_4[i] ** 2);
    end

    for (int i = 0; i < 64; i++) begin
      Orientation_1[i] = ($atan2(Gy_1[i], Gx_1[i]) * 180 / pi >= 0) ? $atan2(Gy_1[i], Gx_1[i]) * 180 / pi : $atan2(Gy_1[i], Gx_1[i]) * 180 / pi + 180;
      Orientation_2[i] = ($atan2(Gy_2[i], Gx_2[i]) * 180 / pi >= 0) ? $atan2(Gy_2[i], Gx_2[i]) * 180 / pi : $atan2(Gy_2[i], Gx_2[i]) * 180 / pi + 180;
      Orientation_3[i] = ($atan2(Gy_3[i], Gx_3[i]) * 180 / pi >= 0) ? $atan2(Gy_3[i], Gx_3[i]) * 180 / pi : $atan2(Gy_3[i], Gx_3[i]) * 180 / pi + 180;
      Orientation_4[i] = ($atan2(Gy_4[i], Gx_4[i]) * 180 / pi >= 0) ? $atan2(Gy_4[i], Gx_4[i]) * 180 / pi : $atan2(Gy_4[i], Gx_4[i]) * 180 / pi + 180;
    end

    for (int i = 0; i < 9; i++) begin
      bin_1[i] = 0;
      bin_2[i] = 0;
      bin_3[i] = 0;
      bin_4[i] = 0;
    end
    
    for (int i = 0; i < 64; i++) begin
      bin_1[(int'($floor(Orientation_1[i] / 20))) % 9] += Magnitude_1[i];
      bin_2[(int'($floor(Orientation_2[i] / 20))) % 9] += Magnitude_2[i];
      bin_3[(int'($floor(Orientation_3[i] / 20))) % 9] += Magnitude_3[i];
      bin_4[(int'($floor(Orientation_4[i] / 20))) % 9] += Magnitude_4[i];
    end
    `ifdef DEBUG
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_1[%2d]: %10.6f, Gy_1[%2d]: %10.6f, Magnitude_1[%2d]: %10.6f, Orientation_1[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_1[i], i, Gy_1[i], i, Magnitude_1[i], i, Orientation_1[i], i, int'(Orientation_1[i] / 20) % 9));
      end
        $display(" ");
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_2[%2d]: %10.6f, Gy_2[%2d]: %10.6f, Magnitude_2[%2d]: %10.6f, Orientation_2[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_2[i], i, Gy_2[i], i, Magnitude_2[i], i, Orientation_2[i], i, int'(Orientation_2[i] / 20) % 9));
      end
        $display(" ");
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_3[%2d]: %10.6f, Gy_3[%2d]: %10.6f, Magnitude_3[%2d]: %10.6f, Orientation_3[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_3[i], i, Gy_3[i], i, Magnitude_3[i], i, Orientation_3[i], i, int'(Orientation_3[i] / 20) % 9));
      end
        $display(" ");
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_4[%2d]: %10.6f, Gy_4[%2d]: %10.6f, Magnitude_4[%2d]: %10.6f, Orientation_4[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_4[i], i, Gy_4[i], i, Magnitude_4[i], i, Orientation_4[i], i, int'(Orientation_4[i] / 20) % 9));
      end
        $display(" ");
    `endif

    sum = epsilon;
    for (int i = 0; i < 9; i++) begin
      sum += bin_1[i];
      sum += bin_2[i];
      sum += bin_3[i];
      sum += bin_4[i];
    end
    `ifdef DEBUG
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("bin_1[%0d]: %f", i, bin_1[i]));
      end
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("bin_2[%0d]: %f", i, bin_2[i]));
      end
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("bin_3[%0d]: %f", i, bin_3[i]));
      end
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("bin_4[%0d]: %f", i, bin_4[i]));
      end

      $display($sformatf("sum: %f", sum));
    `endif

    for (int i = 0; i < 9; i++) begin
      temp_fea_a[i] = $sqrt(bin_1[i] / sum);
      temp_fea_b[i] = $sqrt(bin_2[i] / sum);
      temp_fea_c[i] = $sqrt(bin_3[i] / sum);
      temp_fea_d[i] = $sqrt(bin_4[i] / sum);
    end

    `ifdef DEBUG
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("temp_fea_a[%0d]: %f", i, temp_fea_a[i]));
      end
      $display(" ");
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("temp_fea_b[%0d]: %f", i, temp_fea_b[i]));
      end
      $display(" ");
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("temp_fea_c[%0d]: %f", i, temp_fea_c[i]));
      end
      $display(" ");
      for (int i = 0; i < 9; i++) begin
        $display($sformatf("temp_fea_d[%0d]: %f", i, temp_fea_d[i]));
      end
    `endif 
  endfunction

  function void cal_svm(real fea_a_svm[15][7][9], real fea_b_svm[15][7][9], real fea_c_svm[15][7][9], real fea_d_svm[15][7][9]);
    sum_svm = 0;
    for (int i = 0; i < 15; i ++) begin
      for (int j = 0; j < 7; j ++) begin
        for (int k = 0; k < 9; k ++) begin
          sum_svm = sum_svm + 1.0 * fea_a_svm[i][j][k] * temp_coef_a[i][j][k];
          sum_svm = sum_svm + 1.0 * fea_b_svm[i][j][k] * temp_coef_b[i][j][k];
          sum_svm = sum_svm + 1.0 * fea_c_svm[i][j][k] * temp_coef_c[i][j][k];
          sum_svm = sum_svm + 1.0 * fea_d_svm[i][j][k] * temp_coef_d[i][j][k];
        end
      end
    end
    golden_result.push_back(sum_svm);
  endfunction

  function void build_phase(uvm_phase phase);
    drv_item_collected_export = new("drv_item_collected_export", this);
    mon_item_collected_export = new("mon_item_collected_export", this);

    for (int i = 0; i < 420; i++) begin
      coef_name = {"coef_", $sformatf("%0d", i)};
      if (!uvm_config_db#(logic [9 * (int_part + frac_part) - 1:0])::get(this, "*", coef_name, test_coef[i])) begin
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
          if (coef_a_cal[i][j][(k+1) * (frac_part + int_part) - 1] == 1'b1) begin  
            temp_coef_a[i][j][k] = -1.0*(~coef_a_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)] + 1'b1)/2**frac_part;
          end
          else begin
            temp_coef_a[i][j][k]= (1.0 * (coef_a_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)]) / 2 ** frac_part);
          end
    
          if (coef_b_cal[i][j][(k+1) * (frac_part + int_part) - 1] == 1'b1) begin  
            temp_coef_b[i][j][k] = -1.0*(~coef_b_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)] + 1'b1)/2**frac_part;
          end
          else begin
            temp_coef_b[i][j][k]= (1.0 * (coef_b_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)]) / 2 ** frac_part);
          end
    
          if (coef_c_cal[i][j][(k+1) * (frac_part + int_part) - 1] == 1'b1) begin  
            temp_coef_c[i][j][k] = -1.0*(~coef_c_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)] + 1'b1)/2**frac_part;
          end
          else begin
            temp_coef_c[i][j][k]= (1.0 * (coef_c_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)]) / 2 ** frac_part);
          end
    
          if (coef_d_cal[i][j][(k+1) * (frac_part + int_part) - 1] == 1'b1) begin  
            temp_coef_d[i][j][k] = -1.0*(~coef_d_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)] + 1'b1)/2**frac_part;
          end
          else begin
            temp_coef_d[i][j][k]= (1.0 * (coef_d_cal[i][j][k*(frac_part + int_part)+:(frac_part + int_part)]) / 2 ** frac_part);
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

    row = 0;
    col = 0;

    cnt = 0;
    cnt_compare = 0;

    for (int i = 0; i < 42; i++) begin
      fifo[i] = 0;
    end
  endfunction


  virtual function void write_drv(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)

    for (int j = 41; j > 0; j--) begin
      fifo[j] = fifo[j-1];
    end
    fifo[0] = item.data;

    cnt = cnt + 1;
    `ifdef DEBUG
      $display($sformatf("cnt = %0d", cnt));
      for (int i = 0; i < cnt; i++) begin
        $display($sformatf("FIFO[%0d]: %h", i, fifo[i]));
      end
    `endif
    if (cnt == 42) begin
      if (cnt_addr % 40 != 0) begin
        `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
        data_1 = fifo[41];
        data_2 = fifo[40];
        data_3 = fifo[1];
        data_4 = fifo[0];

        extract_feature(data_1, data_2, data_3, data_4);
        $display("Fea_a_debug: %f", temp_fea_a[0]);
        $display("Fea_b_debug: %f", temp_fea_b[0]);
        $display("Fea_c_debug: %f", temp_fea_c[0]);
        $display("Fea_c_debug: %f", temp_fea_d[0]);


        drv_fea_a[row][col % 39] = temp_fea_a;
        drv_fea_b[row][col % 39] = temp_fea_b;
        drv_fea_c[row][col % 39] = temp_fea_c;
        drv_fea_d[row][col % 39] = temp_fea_d;

        if (col % 39 >= 6 && row >= 14) begin
          // $display("Enter frame num: %d", count);
          // count ++;
          for (int i = 0; i < 15; i++) begin
            for (int j = 0; j < 7; j++) begin
              fea_a_cal[i][j] = drv_fea_a[i + row - 14][j + col % 39 - 6];
              fea_b_cal[i][j] = drv_fea_b[i + row - 14][j + col % 39 - 6];
              fea_c_cal[i][j] = drv_fea_c[i + row - 14][j + col % 39 - 6];
              fea_d_cal[i][j] = drv_fea_d[i + row - 14][j + col % 39 - 6];
            end
          end
          cal_svm(fea_a_cal, fea_b_cal, fea_c_cal, fea_d_cal);
          $display("call svm");
        end
        col ++;
        if (col % 39 == 0) row ++;
      end
      cnt = cnt - 1;
    end

    cnt_addr ++;

    if (cnt_addr == 1200) begin
      cnt = 0;
      cnt_addr = 0;
      for (int i = 0; i < 42; i++) begin
        fifo[i] = 0;
      end
      for (int i = 0; i < 29; i++) begin
        for (int j = 0; j < 39; j++) begin
          for (int k = 0; k < 9; k++) begin
            drv_fea_a[i][j][k] = 0;
            drv_fea_b[i][j][k] = 0;
            drv_fea_c[i][j][k] = 0;
            drv_fea_d[i][j][k] = 0;
          end
        end
      end
      col = 0;
      row = 0;
    end
  endfunction

  virtual function void write_mon(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    if (item.result[int_part + frac_part - 1] == 1'b1) begin  
      temp_result_mon = -1.0*(~item.result + 1'b1)/(2**frac_part);
    end
    else begin
      temp_result_mon= (1.0 * item.result / (2 ** frac_part));
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
    $display("Golden size: %0d", golden_result.size());
    $display("Mon size: %0d", mon_result.size());
    cnt_compare = 0;
    while (mon_result.size() > 0 && golden_result.size() > 0) begin
      $display(cnt_compare);
      if ((mon_result[0] - golden_result[0]) > 1e-2 || (mon_result[0] - golden_result[0]) < -1e-2) begin
        `uvm_error(get_type_name(), "Result is not match")
        `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", golden_result[0], mon_result[0]), UVM_LOW)
      end
      else begin
        `uvm_info(get_type_name(), "Result PASS", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", golden_result[0], mon_result[0]), UVM_LOW)
      end
      cnt_compare ++;
      mon_result.pop_front();
      golden_result.pop_front();
    end
  endfunction


endclass