interface dut_if #(
    parameter  PIX_W  = 8,                // pixel width
    parameter  MAG_F  = 4,                // fraction part of magnitude
    parameter  TAN_I  = 4,                // tan width
    parameter  TAN_F  = 16,               // tan width
    parameter  BIN_I  = 16,               // integer part of bin
    parameter  FEA_I  = 4,                // integer part of hog feature
    parameter  FEA_F  = 8,                // fractional part of hog feature
    parameter  SW_W   = 11,               // slide window width
    localparam IN_W   = PIX_W * 4,
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

  logic [IN_W - 1 : 0] i_data = 0;
  logic                  ready = 0;
  logic                  request = 0;

  logic [ADDR_W - 1 : 0] addr_a = 0;
  logic                  write_en = 0;
  logic [RAM_DW - 1 : 0] i_data_a = 0;
  logic [RAM_DW - 1 : 0] o_data_a = 0;
  logic                  bias = 0;
  logic                  b_load = 0;
  
  logic                  is_person;
  logic                  o_valid;
  logic [ FEA_W - 1 : 0] result;
  logic [  SW_W - 1 : 0] sw_id;


  clocking cb @(posedge clk);
    default input #1ps output #1ps;
    output ready, i_data, addr_a, write_en, i_data_a, bias, b_load;
    input is_person, o_valid, result, sw_id, request, o_data_a;
  endclocking
endinterface
