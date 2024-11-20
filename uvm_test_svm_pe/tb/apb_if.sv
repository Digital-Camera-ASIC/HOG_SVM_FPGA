interface dut_if #(
    parameter FEA_I = 4,
    parameter FEA_F = 28
) (
    input bit clk,
    input bit rst
);

  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_a;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_b;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_c;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] fea_d;

  logic [9 * (FEA_I + FEA_F) - 1 : 0] coef_a;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] coef_b;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] coef_c;
  logic [9 * (FEA_I + FEA_F) - 1 : 0] coef_d;

  logic [(FEA_I + FEA_F) - 1 : 0] i_data;
  logic i_valid;
  logic [(FEA_I + FEA_F) - 1 : 0] o_data;


  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output fea_a, fea_b, fea_c, fea_d, coef_a, coef_b, coef_c, coef_d, i_data, i_valid;
    input o_data;
  endclocking

endinterface
