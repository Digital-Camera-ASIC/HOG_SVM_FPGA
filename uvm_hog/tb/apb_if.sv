interface dut_if #(
    parameter DATA_W = 768
) (
    input bit clk,
    input bit rst
);

  logic [DATA_W - 1 : 0] i_data = 0;
  logic                  ready = 0;
  logic                  request = 0;
  logic [          12:0] bid;
  logic [         287:0] fea_a;
  logic [         287:0] fea_b;
  logic [         287:0] fea_c;
  logic [         287:0] fea_d;
  logic                  o_valid;


  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output ready, i_data;
    input bid, fea_a, fea_b, fea_c, fea_d, o_valid, request;
  endclocking
endinterface
