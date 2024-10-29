`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)

  parameter real pi = 3.141592653589793;
  
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

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void extract_feature(logic [767:0] data_1, logic [767:0] data_2, logic [767:0] data_3,
                                logic [767:0] data_4);
    $display($sformatf("data_1: %d, data_2: %d, data_3: %d, data_4: %d", data_1, data_2, data_3, data_4));

    //  DEBUG --------------------- 
    // $display($sformatf("x: %h, y: %h, z: %h, t: %h", data_1[8*0+:8], data_2[8*0+:8], data_3[8*0+:8], data_4[8*0+:8]));

    // $display($sformatf("x: %h, y: %h", data_1[8*2+:8], data_1[8*0+:8]));
    // $display($sformatf("bieu thuc x - y: %f", (data_1[8*2+:8] - data_1[8*0+:8]) * 1.0 ));

    // $display($sformatf("x: %h, y: %h", data_2[8*2+:8], data_2[8*0+:8]));
    // $display($sformatf("bieu thuc x - y: %f", (data_2[8*2+:8]  - data_2[8*0+:8]) * 1.0));

    // $display($sformatf("x: %h, y: %h", data_3[8*2+:8], data_3[8*0+:8]));
    // $display($sformatf("bieu thuc x - y: %f", data_3[8*2+:8] * 1.0 - data_3[8*0+:8]));

    // $display($sformatf("x: %h, y: %h", data_4[8*2+:8], data_4[8*0+:8]));
    // $display($sformatf("bieu thuc x - y: %f", data_4[8*2+:8] * 1.0 - data_4[8*0+:8]));


      $display($sformatf("atan2(gy,gx) : %f", $atan2(-41, 0.01) * 180/ pi));
     //---------------------         


    // sum = 0;
    // for (int i = 0; i < 288; i = i + 32) begin
    //   sum = sum + 1.0 * (data_1[i+:32]) / 2 ** 16;
    //   sum = sum + 1.0 * (data_2[i+:32]) / 2 ** 16;
    //   sum = sum + 1.0 * (data_3[i+:32]) / 2 ** 16;
    //   sum = sum + 1.0 * (data_4[i+:32]) / 2 ** 16;
    // end
    // $display("index: %0d", cnt_debug++);
    // $display("Sum : %f", sum);
    // for (int i = 0; i < 288; i = i + 32) begin
    //   temp_fea_a[i/32] = $sqrt((1.0 * (data_1[i+:32]) / 2 ** 16) / sum);
    //   temp_fea_b[i/32] = $sqrt((1.0 * (data_2[i+:32]) / 2 ** 16) / sum);
    //   temp_fea_c[i/32] = $sqrt((1.0 * (data_3[i+:32]) / 2 ** 16) / sum);
    //   temp_fea_d[i/32] = $sqrt((1.0 * (data_4[i+:32]) / 2 ** 16) / sum);
    // end
    // q_fea_a_golden.push_back(temp_fea_a);
    // q_fea_b_golden.push_back(temp_fea_b);
    // q_fea_c_golden.push_back(temp_fea_c);
    // q_fea_d_golden.push_back(temp_fea_d);
    // $display($sformatf("--------------------"));

    // $display($sformatf("data_1: %h, data_2: %h, data_3: %h, data_4: %h", data_1, data_2, data_3, data_4));

    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature a[%0d]: %f", i, temp_fea_a[i]));
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature b[%0d]: %f", i, temp_fea_b[i]));
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature c[%0d]: %f", i, temp_fea_c[i]));
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature d[%0d]: %f", i, temp_fea_d[i]));
    // end

    // $display($sformatf("--------------------"));


    // Gx_1[0] = data_1[1*8+:8] - data_1[80*8+:8];
    // Gx_1[8] = data_1[9*8+:8] - data_1[81*8+:8];
    // Gx_1[16] = data_1[17*8+:8] - data_1[82*8+:8];
    // Gx_1[24] = data_1[25*8+:8] - data_1[83*8+:8];
    // Gx_1[32] = data_1[33*8+:8] - data_1[84*8+:8];
    // Gx_1[40] = data_1[41*8+:8] - data_1[85*8+:8];
    // Gx_1[48] = data_1[49*8+:8] - data_1[86*8+:8];
    // Gx_1[56] = data_1[57*8+:8] - data_1[87*8+:8];

    // Gx_1[7] = data_1[88*8+:8] - data_1[6*8+:8];
    // Gx_1[15] = data_1[89*8+:8] - data_1[14*8+:8];
    // Gx_1[23] = data_1[90*8+:8] - data_1[22*8+:8];
    // Gx_1[31] = data_1[91*8+:8] - data_1[30*8+:8];
    // Gx_1[39] = data_1[92*8+:8] - data_1[38*8+:8];
    // Gx_1[47] = data_1[93*8+:8] - data_1[46*8+:8];
    // Gx_1[55] = data_1[94*8+:8] - data_1[54*8+:8];
    // Gx_1[63] = data_1[95*8+:8] - data_1[62*8+:8];

    for (int i = 0; i < 8; i++) begin
      Gx_1[i*8] = 1.0 * data_1[(i*8 + 1)*8+:8] - 1.0 * data_1[(80 + i)*8+:8];
      Gx_2[i*8] = 1.0 * data_2[(i*8 + 1)*8+:8] - 1.0 * data_2[(80 + i)*8+:8];
      Gx_3[i*8] = 1.0 * data_3[(i*8 + 1)*8+:8] - 1.0 * data_3[(80 + i)*8+:8];
      Gx_4[i*8] = 1.0 * data_4[(i*8 + 1)*8+:8] - 1.0 * data_4[(80 + i)*8+:8];
    end

    for (int i = 0; i < 8; i++) begin
      Gx_1[i*8 + 7] = 1.0 * data_1[(88 + i)*8+:8] - 1.0 * data_1[(6 + i*8)*8+:8];
      Gx_2[i*8 + 7] = 1.0 * data_2[(88 + i)*8+:8] - 1.0 * data_2[(6 + i*8)*8+:8];
      Gx_3[i*8 + 7] = 1.0 * data_3[(88 + i)*8+:8] - 1.0 * data_3[(6 + i*8)*8+:8];
      Gx_4[i*8 + 7] = 1.0 * data_4[(88 + i)*8+:8] - 1.0 * data_4[(6 + i*8)*8+:8];
    end

    for (int i = 0; i < 8; i ++) begin
      for (int j = 1; j < 7; j++) begin
        Gx_1[i * 8 + j] = 1.0 * data_1[((i*8+j + 1)*8) +: 8] - 1.0 * data_1[((i*8+j - 1)*8) +: 8];
        Gx_2[i * 8 + j] = 1.0 * data_2[((i*8+j + 1)*8) +: 8] - 1.0 * data_2[((i*8+j - 1)*8) +: 8];
        Gx_3[i * 8 + j] = 1.0 * data_3[((i*8+j + 1)*8) +: 8] - 1.0 * data_3[((i*8+j - 1)*8) +: 8];
        Gx_4[i * 8 + j] = 1.0 * data_4[((i*8+j + 1)*8) +: 8] - 1.0 * data_4[((i*8+j - 1)*8) +: 8];
      end
    end


    // Gy_1[0] = data_1[8*8+:8] - data_1[64*8+:8];
    // Gy_1[1] = data_1[9*8+:8] - data_1[65*8+:8];
    // Gy_1[2] = data_1[10*8+:8] - data_1[66*8+:8];
    // Gy_1[3] = data_1[11*8+:8] - data_1[67*8+:8];
    // Gy_1[4] = data_1[12*8+:8] - data_1[68*8+:8];
    // Gy_1[5] = data_1[13*8+:8] - data_1[69*8+:8];
    // Gy_1[6] = data_1[14*8+:8] - data_1[70*8+:8];
    // Gy_1[7] = data_1[15*8+:8] - data_1[71*8+:8];

    for (int i = 0; i < 8; i++) begin
      Gy_1[i] = 1.0 * data_1[(8 + i)*8+:8] - 1.0 * data_1[(64 + i)*8+:8];
      Gy_2[i] = 1.0 * data_2[(8 + i)*8+:8] - 1.0 * data_2[(64 + i)*8+:8];
      Gy_3[i] = 1.0 * data_3[(8 + i)*8+:8] - 1.0 * data_3[(64 + i)*8+:8];
      Gy_4[i] = 1.0 * data_4[(8 + i)*8+:8] - 1.0 * data_4[(64 + i)*8+:8];
    end

    // Gy_1[56] = data_1[72*8+:8] - data_1[56*8+:8];
    // Gy_1[57] = data_1[73*8+:8] - data_1[57*8+:8];
    // Gy_1[58] = data_1[74*8+:8] - data_1[58*8+:8];
    // Gy_1[59] = data_1[75*8+:8] - data_1[59*8+:8];
    // Gy_1[60] = data_1[76*8+:8] - data_1[60*8+:8];
    // Gy_1[61] = data_1[77*8+:8] - data_1[61*8+:8];
    // Gy_1[62] = data_1[78*8+:8] - data_1[62*8+:8];
    // Gy_1[63] = data_1[79*8+:8] - data_1[63*8+:8];

    for (int i = 0; i < 8; i++) begin
      Gy_1[56 + i] = 1.0 * data_1[(72 + i)*8+:8] - 1.0 * data_1[(56 + i)*8+:8];
      Gy_2[56 + i] = 1.0 * data_2[(72 + i)*8+:8] - 1.0 * data_2[(56 + i)*8+:8];
      Gy_3[56 + i] = 1.0 * data_3[(72 + i)*8+:8] - 1.0 * data_3[(56 + i)*8+:8];
      Gy_4[56 + i] = 1.0 * data_4[(72 + i)*8+:8] - 1.0 * data_4[(56 + i)*8+:8];
    end

    for (int i = 1; i < 7; i++) begin
      for (int j = 0; j < 8; j++) begin
        Gy_1[i*8 + j] = 1.0 * data_1[((i*8 + j + 8)*8) +: 8] - 1.0 * data_1[((i*8 + j - 8)*8) +: 8];
        Gy_2[i*8 + j] = 1.0 * data_2[((i*8 + j + 8)*8) +: 8] - 1.0 * data_2[((i*8 + j - 8)*8) +: 8];
        Gy_3[i*8 + j] = 1.0 * data_3[((i*8 + j + 8)*8) +: 8] - 1.0 * data_3[((i*8 + j - 8)*8) +: 8];
        Gy_4[i*8 + j] = 1.0 * data_4[((i*8 + j + 8)*8) +: 8] - 1.0 * data_4[((i*8 + j - 8)*8) +: 8];
      end
    end

    for (int i = 0; i < 64; i++) begin
      $display($sformatf("Gx_1[%0d]: %f, Gy_1[%0d]: %f", i, Gx_1[i], i, Gy_1[i]));
      $display($sformatf("Gx_2[%0d]: %f, Gy_2[%0d]: %f", i, Gx_2[i], i, Gy_2[i]));
      $display($sformatf("Gx_3[%0d]: %f, Gy_3[%0d]: %f", i, Gx_3[i], i, Gy_3[i]));
      $display($sformatf("Gx_4[%0d]: %f, Gy_4[%0d]: %f", i, Gx_4[i], i, Gy_4[i]));
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
      bin_1[(int'(Orientation_1[i]) / 20) % 9] += Magnitude_1[i];
      bin_2[(int'(Orientation_2[i]) / 20) % 9] += Magnitude_2[i];
      bin_3[(int'(Orientation_3[i]) / 20) % 9] += Magnitude_3[i];
      bin_4[(int'(Orientation_4[i]) / 20) % 9] += Magnitude_4[i];
    end

    for (int i = 0; i < 64; i++) begin
      $display($sformatf("Magnitude_1 [%0d]: %f, Orientation_1 [%0d]: %f", i, Magnitude_1[i], i, Orientation_1[i]));
      $display($sformatf("Magnitude_2 [%0d]: %f, Orientation_2 [%0d]: %f", i, Magnitude_2[i], i, Orientation_2[i]));
      $display($sformatf("Magnitude_3 [%0d]: %f, Orientation_3 [%0d]: %f", i, Magnitude_3[i], i, Orientation_3[i]));
      $display($sformatf("Magnitude_4 [%0d]: %f, Orientation_4 [%0d]: %f", i, Magnitude_4[i], i, Orientation_4[i]));
    end

    sum = 0;
    for (int i = 0; i < 9; i++) begin
      sum += bin_1[i];
      sum += bin_2[i];
      sum += bin_3[i];
      sum += bin_4[i];
    end

    for (int i = 0; i < 9; i++) begin
      temp_fea_a[i] = $sqrt(bin_1[i] / sum);
      temp_fea_b[i] = $sqrt(bin_2[i] / sum);
      temp_fea_c[i] = $sqrt(bin_3[i] / sum);
      temp_fea_d[i] = $sqrt(bin_4[i] / sum);
    end

    q_fea_a_golden.push_back(temp_fea_a);
    q_fea_b_golden.push_back(temp_fea_b);
    q_fea_c_golden.push_back(temp_fea_c);
    q_fea_d_golden.push_back(temp_fea_d);

    
  endfunction

  function void build_phase(uvm_phase phase);
    drv_item_collected_export = new("drv_item_collected_export", this);
    mon_item_collected_export = new("mon_item_collected_export", this);
    cnt = 0;
    cnt_compare = 0;
    for (int i = 0; i < 42; i++) begin
      fifo[i] = 0;
    end
  endfunction


  virtual function void write_drv(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)

    // if (item.i_valid == 1) begin
    for (int j = 41; j > 0; j--) begin
      fifo[j] = fifo[j-1];
    end
    fifo[0] = item.data;
    cnt = cnt + 1;
    $display($sformatf("cnt = %0d", cnt));
    for (int i = 0; i < cnt; i++) begin
      $display($sformatf("FIFO[%0d]: %h", i, fifo[i]));
    end
    if (cnt == 42) begin
      // Tinh toan feature de so sanh
      // if (item.addr % 40 != 0) begin
      `uvm_info(get_type_name(), "Feature valid message", UVM_LOW)
      data_1 = fifo[41];
      data_2 = fifo[40];
      data_3 = fifo[1];
      data_4 = fifo[0];
      extract_feature(data_1, data_2, data_3, data_4);
      // end
      cnt = cnt - 1;
    end
    // end
  endfunction

  virtual function void write_mon(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    // for (int i = 0; i < 288; i = i + 32) begin
    //   temp_fea_a[i/32] = 1.0 * (item.fea_a[i+:32]) / 2 ** 28;  //1.0*(data_1[i +: 32]) / 2**16
    //   temp_fea_b[i/32] = 1.0 * (item.fea_b[i+:32]) / 2 ** 28;
    //   temp_fea_c[i/32] = 1.0 * (item.fea_c[i+:32]) / 2 ** 28;
    //   temp_fea_d[i/32] = 1.0 * (item.fea_d[i+:32]) / 2 ** 28;
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature a[%0d]: %f", i, temp_fea_a[i]));
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature b[%0d]: %f", i, temp_fea_b[i]));
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature c[%0d]: %f", i, temp_fea_c[i]));
    // end
    // for (int i = 0; i < 9; i++) begin
    //   $display($sformatf("feature d[%0d]: %f", i, temp_fea_d[i]));
    // end
    // q_fea_a.push_back(temp_fea_a);
    // q_fea_b.push_back(temp_fea_b);
    // q_fea_c.push_back(temp_fea_c);
    // q_fea_d.push_back(temp_fea_d);
  endfunction

  // virtual function void extract_phase(uvm_phase phase);
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
  //       if ((q_fea_b_golden[0][i] - q_fea_b[0][i]) > 1e-6 || (q_fea_b_golden[0][i] - q_fea_b[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature b[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_b_golden[0][i],
  //                                              q_fea_b[0][i]), UVM_LOW)
  //       end
  //       if ((q_fea_c_golden[0][i] - q_fea_c[0][i]) > 1e-6 || (q_fea_c_golden[0][i] - q_fea_c[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature c[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_c_golden[0][i],
  //                                              q_fea_c[0][i]), UVM_LOW)
  //       end
  //       if ((q_fea_d_golden[0][i] - q_fea_d[0][i]) > 1e-6 || (q_fea_d_golden[0][i] - q_fea_d[0][i]) < -1e-6) begin
  //         `uvm_error(get_type_name(), $sformatf("Feature d[%0d] is not match", i))
  //         `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", q_fea_d_golden[0][i],
  //                                              q_fea_d[0][i]), UVM_LOW)
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
  //   end
  // endfunction


endclass
