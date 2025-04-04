`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  // `define DEBUG 1

  parameter real pi = 3.141592653589793;
  parameter real epsilon = 0.00390625;
  parameter int FEA_F = 12;

  real Gx[42][64];
  real Gy[42][64];

  real top;
  real bot;
  real left;
  real right;
  real orientation;

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
  real q_fea_print[$];

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
                              
    // $display("My debug");
    // for (int i = 0; i < 64; i++) begin
    //   $display($sformatf("Gx_1[%0d]: %f, Gy_1[%0d]: %f", i, Gx_1[i], i, Gy_1[i]));
    // end
    // for (int i = 0; i < 64; i++) begin
    //   $display($sformatf("Gx_2[%0d]: %f, Gy_2[%0d]: %f", i, Gx_2[i], i, Gy_2[i]));
    // end
    // for (int i = 0; i < 64; i++) begin
    //   $display($sformatf("Gx_3[%0d]: %f, Gy_3[%0d]: %f", i, Gx_3[i], i, Gy_3[i]));
    // end
    // for (int i = 0; i < 64; i++) begin
    //   $display($sformatf("Gx_4[%0d]: %f, Gy_4[%0d]: %f", i, Gx_4[i], i, Gy_4[i]));
    // end
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
        $display($sformatf("Gx_1[%2d]: %10.6f, Gy_1[%2d]: %10.6f, Magnitude_1[%2d]: %10.6f, Orientation_1[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_1[i], i, Gy_1[i], i, Magnitude_1[i], i, Orientation_1[i], i, int'($floor(Orientation_1[i] / 20)) % 9));
      end
        $display(" ");
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_2[%2d]: %10.6f, Gy_2[%2d]: %10.6f, Magnitude_2[%2d]: %10.6f, Orientation_2[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_2[i], i, Gy_2[i], i, Magnitude_2[i], i, Orientation_2[i], i, int'($floor(Orientation_2[i] / 20)) % 9));
      end
        $display(" ");
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_3[%2d]: %10.6f, Gy_3[%2d]: %10.6f, Magnitude_3[%2d]: %10.6f, Orientation_3[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_3[i], i, Gy_3[i], i, Magnitude_3[i], i, Orientation_3[i], i, int'($floor(Orientation_3[i] / 20)) % 9));
      end
        $display(" ");
      for (int i = 0; i < 64; i++) begin
        $display($sformatf("Gx_4[%2d]: %10.6f, Gy_4[%2d]: %10.6f, Magnitude_4[%2d]: %10.6f, Orientation_4[%2d]: %10.6f, In bin[%2d]: %10.6f", i, Gx_4[i], i, Gy_4[i], i, Magnitude_4[i], i, Orientation_4[i], i, int'($floor(Orientation_4[i] / 20)) % 9));
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

    // `ifdef DEBUG
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
    // `endif

    sum += epsilon;

    for (int i = 0; i < 36; i++) begin
      if (i < 9) temp_fea[i] = $sqrt(bin_1[i] / sum);
      else if (i < 18) temp_fea[i] = $sqrt(bin_2[i-9] / sum);
      else if (i < 27) temp_fea[i] = $sqrt(bin_3[i-18] / sum);
      else temp_fea[i] = $sqrt(bin_4[i-27] / sum);
    end

    // `ifdef DEBUG
      for (int i = 0; i < 36; i++) begin
        $display ($sformatf("temp_fea[%0d]: %f", i, temp_fea[i]));
        q_fea_golden.push_back(temp_fea[i]);
        // $display($sformatf("temp_fea[%0d]: %f", i, temp_fea[i]));
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
    // `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)

    // if (item.i_valid == 1) begin
    top = item.data[31:24];
    bot = item. data [23:16];
    left = item.data [15:8];
    right = item.data[7:0]; 

    orientation = ($atan2(bot - top, right - left) * 180 / pi >= 0) ? $atan2(bot - top, right - left) * 180 / pi : $atan2(bot - top, right - left) * 180 / pi + 180;

    // $display("Count: %0d, Count pixel: %0d, Count_addr: %0d", cnt, cnt_pixel, cnt_addr);
    `uvm_info(get_type_name(), $sformatf("Top: %f, Bot: %f, Left: %f, Right: %f", top, bot, left, right), UVM_LOW)
    Gx[0][cnt_pixel] = right - left;
    Gy[0][cnt_pixel] = bot - top;
    // $display($sformatf("Gx: %f, Gy: %f, In bin[%d]: %f", right - left, bot - top, cnt_pixel, int'($floor(orientation / 20)) % 9));
    cnt_pixel = cnt_pixel + 1;
    if (cnt_pixel == 64) begin
      cnt_pixel = 0;
      cnt = cnt + 1;
      if (cnt == 42) begin
        // Do extraction
        if (cnt_addr % 40 != 0) begin
          `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
          // $display("Count_addr: %0d", cnt_addr);
          extract_feature(Gx[41], Gx[40], Gx[1], Gx[0], Gy[41], Gy[40], Gy[1], Gy[0]);
        end
        cnt = cnt - 1;
      end
      for (int i = 41; i > 0; i--) begin
        Gx[i] = Gx[i-1];
        Gy[i] = Gy[i-1];
      end
      cnt_addr = cnt_addr + 1;
    end
    
  endfunction

  virtual function void write_mon(base_item item);
    // `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    q_fea.push_back(1.0 * (item.fea) / 2** FEA_F);
    // $display($sformatf("Feature_mon: %f", 1.0 * (item.fea) / 2**8));
  endfunction

  virtual function void extract_phase(uvm_phase phase);
    q_fea_print = q_fea;
    cnt_compare = q_fea_print.size();
    $display("Size of queue: %0d", q_fea_print.size());
    // $display("Size of queue_mon: %0d", q_fea.size());
    // for (int i = 0; i < cnt_compare; i++) begin
    //   $display($sformatf("Feature[%0d]: %f", i % 36, q_fea_print[0]));
    //   q_fea_print.pop_front();
    //   if (i % 36 == 35) begin
    //     $display(" ");
    //   end
    // end
    cnt_compare = 0;

    `uvm_info(get_type_name(), "Extract phase", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("queue drv size: %0d", q_fea_golden.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("queue mon size: %0d", q_fea.size()), UVM_LOW)

    while (q_fea_golden.size() > 0 && q_fea.size() > 0) begin
      cnt_compare = cnt_compare + 1;
      $display($sformatf("Compare %0d", cnt_compare));
      if ((q_fea_golden[0] - q_fea[0]) > 1e-2 || (q_fea_golden[0] - q_fea[0]) < -1e-2) begin
        `uvm_error(get_type_name(), $sformatf("Feature is not match"))
        `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_golden[0], q_fea[0]), UVM_LOW)
      end
      else begin
        `uvm_info(get_type_name(), $sformatf("PASS"), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_golden[0], q_fea[0]), UVM_LOW)
      end
      q_fea.pop_front();
      q_fea_golden.pop_front();
    end
  endfunction


endclass