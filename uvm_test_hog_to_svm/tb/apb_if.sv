interface dut_if #(
    parameter FEA_I = 4,
    parameter FEA_F = 28,
    parameter SW_W  = 11,
    parameter DATA_W = 768
) (
    input bit clk,
    input bit rst
);

  logic [         DATA_W - 1 : 0] i_data = 0;
  logic                           ready = 0;
  logic                           request = 0;

  logic                           is_person;
  logic                           o_valid;
  logic [(FEA_I + FEA_F - 1) : 0] result;
  logic [           SW_W - 1 : 0] sw_id;


  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output ready, i_data;
    input is_person, o_valid, result, sw_id, request;
  endclocking
endinterface
