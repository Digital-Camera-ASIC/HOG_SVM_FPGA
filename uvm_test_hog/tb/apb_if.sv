interface dut_if #(
    parameter   PIX_W   = 8, // pixel width
    parameter   MAG_F   = 4,// fraction part of magnitude
    parameter   TAN_I   = 4, // tan width
    parameter   TAN_F   = 16, // tan width
    parameter   BIN_I   = 16, // integer part of bin
    parameter   FEA_I   = 4, // integer part of hog feature
    parameter   FEA_F   = 12, // fractional part of hog feature
    localparam  FEA_W   = FEA_I + FEA_F,
    localparam  IN_W    = PIX_W * 4
) (
    input bit clk,
    input bit rst
);

  logic [ IN_W - 1 : 0] i_data = 0;
  logic                 i_valid = 0;
  // logic                  ready = 0;
  // logic                  request = 0;
  logic [FEA_W - 1 : 0] fea = 0;
  logic                 o_valid = 0;


  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output i_data, i_valid;
    input fea, o_valid;
  endclocking
endinterface
