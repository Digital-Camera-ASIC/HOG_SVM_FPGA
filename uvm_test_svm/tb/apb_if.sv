interface dut_if #(
    parameter  FEA_I  = 4,                // integer part of hog feature
    parameter  FEA_F  = 12,                // fractional part of hog feature
    parameter  SW_W   = 11,               // slide window width
    localparam FEA_W  = FEA_I + FEA_F,
    localparam COEF_W = FEA_W,
    localparam ROW    = 15,
    localparam COL    = 7,
    localparam N_COEF = ROW * COL,        // number of coef in a fetch instruction
    localparam RAM_DW = COEF_W * N_COEF,
    localparam ADDR_W = 6                 // ceil of log2(36)
) (
    input bit clk,
    input bit rst
);
  logic [ADDR_W - 1 : 0] addr_a = 0;
  logic write_en = 0;
  logic [RAM_DW - 1 : 0] i_data = 0;
  logic [RAM_DW - 1 : 0] o_data_a = 0;

  logic [COEF_W - 1 : 0] bias = 0;
  logic b_load = 0;

  logic i_valid = 0;
  logic [FEA_W - 1 : 0] fea = 0;

  logic o_valid;
  logic is_person;
  logic [FEA_W - 1 : 0] result;
  logic [SW_W - 1 : 0] sw_id;



  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output addr_a, write_en, i_data, bias, b_load, fea, i_valid;
    input o_data_a, o_valid, is_person, result, sw_id;
  endclocking

endinterface
