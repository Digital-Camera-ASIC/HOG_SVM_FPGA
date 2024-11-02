interface dut_if #(
  parameter DATA_W = 288
)(
  input bit clk,
  input bit rst
);
  logic   [DATA_W - 1 : 0]    bin = 0;
  logic                       i_valid = 0;
  logic                       o_valid = 0;
  logic   [12:0]              addr_fw = 0;
  logic   [12:0]              bid = 0;
  logic   [DATA_W - 1 : 0]    fea_a = 0;
  logic   [DATA_W - 1 : 0]    fea_b = 0;
  logic   [DATA_W - 1 : 0]    fea_c = 0;
  logic   [DATA_W - 1 : 0]    fea_d = 0;
  logic   [12:0]              addr = 0;

  clocking cb @(posedge clk);
      default input #1ps output #1ps;
      output  bin, i_valid, addr_fw, addr;
      input   bid, fea_a, fea_b, fea_c, fea_d, o_valid;
  endclocking
endinterface