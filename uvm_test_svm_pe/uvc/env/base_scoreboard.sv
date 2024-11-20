`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class base_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_drv #(base_item, base_scoreboard) drv_item_collected_export;
  uvm_analysis_imp_mon #(base_item, base_scoreboard) mon_item_collected_export;
  `uvm_component_utils(base_scoreboard)


  real sum_golden[$];
  real sum_mon[$];

  real temp_fea_a[9];
  real temp_fea_b[9];
  real temp_fea_c[9];
  real temp_fea_d[9];

  real temp_coef_a[9];
  real temp_coef_b[9];
  real temp_coef_c[9];
  real temp_coef_d[9];

  real temp_data_mon;

  real temp_idata;


  real sum;
  int cnt;
  int cnt_compare;

  function new(string name = "base_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void extract_feature(logic [287:0] fea_a, logic [287:0] fea_b, logic [287:0] fea_c, logic [287:0] fea_d,
                                logic [287:0] coef_a, logic [287:0] coef_b, logic [287:0] coef_c, logic [287:0] coef_d, logic [31:0] i_data);   
    if (i_data[31] == 1'b1) begin
      sum = -1.0*(~i_data + 1'b1)/2**28;
    end
    else begin
      sum = 1.0 * i_data / 2 ** 28;
    end

    $display("sum i_data : %f", sum);

    $display("fea_a: %h, fea_b: %h, fea_c: %h, fea_d: %h, coef_a: %h, coef_b: %h, coef_c: %h, coef_d: %h, i_data: %h", fea_a, fea_b, fea_c, fea_d, coef_a, coef_b, coef_c, coef_d, i_data);

    for (int i = 0; i < 9; i++) begin
      if (fea_a[(i+1) * 32 - 1] == 1'b1) begin  
        temp_fea_a[i] = -1.0*(~fea_a[i*32+:32] + 1'b1)/2**28;
      end
      else begin
         temp_fea_a[i]= (1.0 * (fea_a[i*32+:32]) / 2 ** 28);
      end

      if (fea_b[(i+1) * 32 - 1] == 1'b1) begin  
        temp_fea_b[i] = -1.0*(~fea_b[i*32+:32] + 1'b1)/2**28;
      end
      else begin
         temp_fea_b[i]= (1.0 * (fea_b[i*32+:32]) / 2 ** 28);
      end

      if (fea_c[(i+1) * 32 - 1] == 1'b1) begin  
        temp_fea_c[i] = -1.0*(~fea_c[i*32+:32] + 1'b1)/2**28;
      end
      else begin
         temp_fea_c[i]= (1.0 * (fea_c[i*32+:32]) / 2 ** 28);
      end

      if (fea_d[(i+1) * 32 - 1] == 1'b1) begin  
        temp_fea_d[i] = -1.0*(~fea_d[i*32+:32] + 1'b1)/2**28;
      end
      else begin
         temp_fea_d[i]= (1.0 * (fea_d[i*32+:32]) / 2 ** 28);
      end

      if (coef_a[(i+1) * 32 - 1] == 1'b1) begin  
        temp_coef_a[i] = -1.0*(~coef_a[i*32+:32] + 1'b1)/2**28;
      end
      else begin
        temp_coef_a[i]= (1.0 * (coef_a[i*32+:32]) / 2 ** 28);
      end

      if (coef_b[(i+1) * 32 - 1] == 1'b1) begin  
        temp_coef_b[i] = -1.0*(~coef_b[i*32+:32] + 1'b1)/2**28;
      end
      else begin
        temp_coef_b[i]= (1.0 * (coef_b[i*32+:32]) / 2 ** 28);
      end

      if (coef_c[(i+1) * 32 - 1] == 1'b1) begin  
        temp_coef_c[i] = -1.0*(~coef_c[i*32+:32] + 1'b1)/2**28;
      end
      else begin
        temp_coef_c[i]= (1.0 * (coef_c[i*32+:32]) / 2 ** 28);
      end

      if (coef_d[(i+1) * 32 - 1] == 1'b1) begin  
        temp_coef_d[i] = -1.0*(~coef_d[i*32+:32] + 1'b1)/2**28;
      end
      else begin
        temp_coef_d[i]= (1.0 * (coef_d[i*32+:32]) / 2 ** 28);
      end
    end
    // $display("temp_a[0]: %f", temp_fea_a[0]);
    // $display("temp_coef_a[0]: %f", temp_coef_a[0]);
    for (int i = 0; i < 9; i++) begin
      $display("temp_fea_a[%0d]: %f, temp_fea_b[%0d]: %f, temp_fea_c[%0d]: %f, temp_fea_d[%0d]: %f", i, temp_fea_a[i], i, temp_fea_b[i], i, temp_fea_c[i], i, temp_fea_d[i]);
      $display("temp_coef_a[%0d]: %f, temp_coef_b[%0d]: %f, temp_coef_c[%0d]: %f, temp_coef_d[%0d]: %f", i, temp_coef_a[i], i, temp_coef_b[i], i, temp_coef_c[i], i, temp_coef_d[i]);
    end
    for (int i = 0; i < 9; i++) begin
      sum = sum + 1.0*temp_fea_a[i] * temp_coef_a[i];
      sum = sum + 1.0*temp_fea_b[i] * temp_coef_b[i];
      sum = sum + 1.0*temp_fea_c[i] * temp_coef_c[i];
      sum = sum + 1.0*temp_fea_d[i] * temp_coef_d[i];
    end

    $display("sum_drv: %f", sum);
    sum_golden.push_back(sum);
  endfunction

  function void build_phase(uvm_phase phase);
    drv_item_collected_export = new("drv_item_collected_export", this);
    mon_item_collected_export = new("mon_item_collected_export", this);
    cnt = 0;
    cnt_compare = 0;

  endfunction


  virtual function void write_drv(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from drv %s", item.sprint()), UVM_LOW)
    extract_feature(item.fea_a, item.fea_b, item.fea_c, item.fea_d, item.coef_a, item.coef_b, item.coef_c, item.coef_d, item.i_data);
  endfunction

  virtual function void write_mon(base_item item);
    `uvm_info(get_type_name(), $sformatf("Captured packet from mon %s", item.sprint()), UVM_LOW)
    if (item.o_data[31] == 1'b1) begin  
        temp_data_mon = -1.0*(~item.o_data + 1'b1)/2**28;
      end
    else begin
      temp_data_mon= (1.0 * item.o_data / 2 ** 28);
    end

    $display("sum_mon: %f", 1.0*item.o_data/2**28);
    sum_mon.push_back(temp_data_mon);
  endfunction

  virtual function void extract_phase(uvm_phase phase);

    `uvm_info(get_type_name(), "Extract phase", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("sum_golden size: %0d", sum_golden.size()),
              UVM_LOW)

    `uvm_info(get_type_name(), $sformatf("sum_mon size: %0d", sum_mon.size()), UVM_LOW)


    while (sum_golden.size() > 0 && sum_mon.size() > 0) begin
      cnt_compare = cnt_compare + 1;
      $display($sformatf("Compare %0d", cnt_compare));
      if (sum_golden[0] - sum_mon[0]  > 1e-6 || sum_golden[0] - sum_mon[0] < -1e-6) begin
        `uvm_error(get_type_name(), $sformatf("sum [%d] not match ", cnt_compare))
        `uvm_info(get_type_name(), $sformatf("Golden: %f, Actual: %f", sum_golden[0],
                                              sum_mon[0]), UVM_LOW)
      end
      else begin
        `uvm_info(get_type_name(), $sformatf("sum [%0d] PASS", cnt_compare), UVM_LOW)
      end
      sum_golden.pop_front();
      sum_mon.pop_front();
    end

  endfunction


endclass
