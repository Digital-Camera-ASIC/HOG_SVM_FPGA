`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  `define DEBUG 1

  parameter real pi = 3.141592653589793;
  parameter real epsilon = 1e-6;

  real Gx[42][64];
  real Gy[42][64];

  real top;
  real bot;
  real left;
  real right;

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


  real temp_fea[36];

  real q_fea_a_golden[$][9];
  real q_fea_b_golden[$][9];
  real q_fea_c_golden[$][9];
  real q_fea_d_golden[$][9];
  real q_fea_golden[$];
  real q_fea[$];

  real temp;
  real sum;
  int cnt = 0;
  int cnt_pixel = 0;
  int cnt_compare = 0;
  int cnt_debug = 0;
  int cnt_addr = 0;

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void extract_feature(real Gx_1[64], real Gx_2[64], real Gx_3[64], real Gx_4[64],
                                real Gy_1[64], real Gy_2[64], real Gy_3[64], real Gy_4[64]);

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

    sum = 0;
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

    sum += epsilon;

    for (int i = 0; i < 36; i++) begin
      if (i < 9) temp_fea[i] = $sqrt(bin_1[i] / sum);
      else if (i < 18) temp_fea[i] = $sqrt(bin_2[i-9] / sum);
      else if (i < 27) temp_fea[i] = $sqrt(bin_3[i-18] / sum);
      else temp_fea[i] = $sqrt(bin_4[i-27] / sum);
    end

    // `ifdef DEBUG
      for (int i = 0; i < 36; i++) begin
        q_fea_golden.push_back(temp_fea[i]);
        $display($sformatf("temp_fea[%0d]: %f", i, temp_fea[i]));
      end
    // `endif 

  endfunction

  function void build_phase(uvm_phase phase);
    drv_item_collected_export = new("drv_item_collected_export", this);
    mon_item_collected_export = new("mon_item_collected_export", this);
    for (int i = 0; i < 42; i++) begin
      for (int j = 0; j < 64; j++) begin
        Gx[i][j] = 0;
        Gy[i][j] = 0;
      end
    end
  endfunction


  virtual function void write_drv(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)

    // if (item.i_valid == 1) begin
    top = item.data[31:24];
    bot = item. data [23:16];
    left = item.data [15:8];
    right = item.data[7:0];
    $display("Count: %0d, Count pixel: %0d, Count_addr: %0d", cnt, cnt_pixel, cnt_addr);
    `uvm_info(get_type_name(), $sformatf("Top: %f, Bot: %f, Left: %f, Right: %f", top, bot, left, right), UVM_LOW)
    Gx[cnt][cnt_pixel] = right - left;
    Gy[cnt][cnt_pixel] = bot - top;

    cnt_pixel = cnt_pixel + 1;
    if (cnt_pixel == 64) begin

      for (int i = 41; i > 0; i--) begin
        for (int j = 0; j < 64; j++) begin
          Gx[i][j] = Gx[i-1][j];
          Gy[i][j] = Gy[i-1][j];
        end
      end

      cnt_pixel = 0;
      cnt = cnt + 1;
      if (cnt == 42) begin
        // Do extraction
        if (cnt_addr % 40 != 0) begin
          `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
          extract_feature(Gx[41], Gx[40], Gx[1], Gx[0], Gy[41], Gy[40], Gy[1], Gy[0]);
          cnt = cnt - 1;
        end
      end
      cnt_addr = cnt_addr + 1;
    end
    // end




    // $display($sformatf("item.data[9]: %h", item.data_temp[9]));
    // // if (item.i_valid == 1) begin
    // for (int j = 41; j > 0; j--) begin
    //   fifo[j] = fifo[j-1];
    // end
    // fifo[0] = item.data;
    // cnt = cnt + 1;
    // `ifdef DEBUG
    //   $display($sformatf("cnt = %0d", cnt));
    //   for (int i = 0; i < cnt; i++) begin
    //     $display($sformatf("FIFO[%0d]: %h", i, fifo[i]));
    //   end
    // `endif
    // if (cnt == 42) begin
    //   // Tinh toan feature de so sanh
    //   if (cnt_addr % 40 != 0) begin
    //     `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
    //     data_1 = fifo[41];
    //     data_2 = fifo[40];
    //     data_3 = fifo[1];
    //     data_4 = fifo[0];
    //     extract_feature(data_1, data_2, data_3, data_4);
    //   end
    //   cnt = cnt - 1;
    // end
    // cnt_addr++;

    // if (cnt_addr == 1200) begin
    //   cnt = 0;
    //   cnt_addr = 0;
    //   for (int i = 0; i < 42; i++) begin
    //     fifo[i] = 0;
    //   end
    // end
    // end
  endfunction

  virtual function void write_mon(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    q_fea.push_back(1.0 * (item.fea) / 2**8);
    $display($sformatf("Feature_mon: %f", 1.0 * (item.fea) / 2**8));
  endfunction

  virtual function void extract_phase(uvm_phase phase);

    // $display("Tinh toan %f", $sqrt(40 * 1.0 / (40 + 41 + 80 + 81)));
    `uvm_info(get_type_name(), "Extract phase", UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_a_golden size: %0d", q_fea_a_golden.size()),
    //           UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_b_golden size: %0d", q_fea_b_golden.size()),
    //           UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_c_golden size: %0d", q_fea_c_golden.size()),
    //           UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_d_golden size: %0d", q_fea_d_golden.size()),
    //           UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_a size: %0d", q_fea_a.size()), UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_b size: %0d", q_fea_b.size()), UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_c size: %0d", q_fea_c.size()), UVM_LOW)
    // `uvm_info(get_type_name(), $sformatf("q_fea_d size: %0d", q_fea_d.size()), UVM_LOW)

    // while (q_fea_a_golden.size() > 0 && q_fea_a.size() > 0) begin
    //   cnt_compare = cnt_compare + 1;
    //   $display($sformatf("Compare %0d", cnt_compare));
    //   for (int i = 0; i < 9; i++) begin
    //     if ((q_fea_a_golden[0][i] - q_fea_a[0][i]) > 1e-6 || (q_fea_a_golden[0][i] - q_fea_a[0][i]) < -1e-6) begin
    //       `uvm_error(get_type_name(), $sformatf("Feature a[%0d] is not match", i))
    //       `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_a_golden[0][i],
    //                                            q_fea_a[0][i]), UVM_LOW)
    //     end
    //     else begin
    //       `uvm_info(get_type_name(), $sformatf("Feature a[%0d] PASS", i), UVM_LOW)
    //     end
    //     if ((q_fea_b_golden[0][i] - q_fea_b[0][i]) > 1e-6 || (q_fea_b_golden[0][i] - q_fea_b[0][i]) < -1e-6) begin
    //       `uvm_error(get_type_name(), $sformatf("Feature b[%0d] is not match", i))
    //       `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_b_golden[0][i],
    //                                            q_fea_b[0][i]), UVM_LOW)
    //     end
    //     else begin
    //       `uvm_info(get_type_name(), $sformatf("Feature b[%0d] PASS", i), UVM_LOW)
    //     end
    //     if ((q_fea_c_golden[0][i] - q_fea_c[0][i]) > 1e-6 || (q_fea_c_golden[0][i] - q_fea_c[0][i]) < -1e-6) begin
    //       `uvm_error(get_type_name(), $sformatf("Feature c[%0d] is not match", i))
    //       `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_c_golden[0][i],
    //                                            q_fea_c[0][i]), UVM_LOW)
    //     end
    //     else begin
    //       `uvm_info(get_type_name(), $sformatf("Feature c[%0d] PASS", i), UVM_LOW)
    //     end
    //     if ((q_fea_d_golden[0][i] - q_fea_d[0][i]) > 1e-6 || (q_fea_d_golden[0][i] - q_fea_d[0][i]) < -1e-6) begin
    //       `uvm_error(get_type_name(), $sformatf("Feature d[%0d] is not match", i))
    //       `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_d_golden[0][i],
    //                                            q_fea_d[0][i]), UVM_LOW)
    //     end
    //     else begin
    //       `uvm_info(get_type_name(), $sformatf("Feature d[%0d] PASS", i), UVM_LOW)
    //     end
    //   end
    //   q_fea_a.pop_front();
    //   q_fea_b.pop_front();
    //   q_fea_c.pop_front();
    //   q_fea_d.pop_front();
    //   q_fea_a_golden.pop_front();
    //   q_fea_b_golden.pop_front();
    //   q_fea_c_golden.pop_front();
    //   q_fea_d_golden.pop_front();
    // end



    // TEST 




  endfunction


endclass
