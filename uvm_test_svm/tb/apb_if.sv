interface dut_if #(
    parameter FEA_I = 4,
    parameter FEA_F = 28,
    parameter SW_W = 11
) (
    input bit clk,
    input bit rst
);

  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_a = 0;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_b = 0;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_c = 0;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_d = 0;
  logic i_valid = 0;

  logic is_person;
  logic o_valid;
  logic [(FEA_I + FEA_F) - 1 : 0] result;
  logic [SW_W - 1 : 0] sw_id;



  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output fea_a, fea_b, fea_c, fea_d, i_valid;
    input is_person, o_valid, result, sw_id;
  endclocking

endinterface
