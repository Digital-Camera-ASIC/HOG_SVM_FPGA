
module hog_svm#(
    parameter   PIX_W   = 8, // pixel width
    parameter   MAG_F   = 4,// fraction part of magnitude
    parameter   TAN_I   = 4, // tan width
    parameter   TAN_F   = 16, // tan width
    parameter   BIN_I   = 16, // integer part of bin
    parameter   FEA_I   = 4, // integer part of hog feature
    parameter   FEA_F   = 16, // fractional part of hog feature
    parameter   SW_W    = 11, // slide window width
    parameter   CELL_S  = 10, // Size of cell, default 8x8 pixel and border
    localparam  PIX_N   = CELL_S * CELL_S - 4, // number of cell 
    localparam  IN_W    = PIX_W * PIX_N,
    localparam  FEA_W   = FEA_I + FEA_F,
    localparam  COEF_W  = FEA_W,
    localparam  ROW     = 15,
    localparam  COL     = 7,
    localparam  N_COEF  = ROW * COL, // number of coef in a fetch instruction
    localparam  RAM_DW  = COEF_W * N_COEF,
    localparam  ADDR_W  = 6 // ceil of log2(36)
)(
    //// hog if
    input                       clk,
    input                       rst,
    input                       ready,
    output                      request,
    input   [IN_W - 1   : 0]    i_data_fetch,
    //// svm if
    // ram interface
    input   [ADDR_W - 1 : 0]    addr_a,
    input                       write_en,
    input   [RAM_DW - 1 : 0]    i_data_a,
    output  [RAM_DW - 1 : 0]    o_data_a,
    // bias
    input   [COEF_W - 1 : 0]    bias,
    input                       b_load,
    // output info
    output                      o_valid,
    output                      is_person,
`ifdef SIM
    output  [FEA_W - 1  : 0]    result,
`endif
    output  [SW_W - 1   : 0]    sw_id // slide window index
);
    wire [FEA_W - 1 : 0]          fea_sig;
    wire     i_valid_sig;
    wire     i_valid_hog;
    wire [PIX_W * 4 - 1 : 0] i_data_hog;
    hog_fetch #(
        .PIX_W      (PIX_W),
        .CELL_S     (CELL_S)
        // Size of cell, default 8x8 pixel and border
    ) u_hog_fetch (
        .clk        (clk),
        .rst        (rst),
        // fifo if
        .ready      (ready),
        .request    (request),
        .i_data     (i_data_fetch),
        // hog if
        .i_valid    (i_valid_hog),
        // top, bot left, right
        .o_data     (i_data_hog)
    );
    hog #(
        .PIX_W      (PIX_W),
        // pixel width
        .MAG_F      (MAG_F),
        // fraction part of magnitude
        .TAN_I      (TAN_I),
        // tan width
        .TAN_F      (TAN_F),
        // tan width
        .BIN_I      (BIN_I),
        // integer part of bin
        .FEA_I      (FEA_I),
        // integer part of hog feature
        .FEA_F      (FEA_F)
        // fractional part of hog feature
    ) u_hog (
        .clk        (clk),
        .rst        (rst),
        .i_valid    (i_valid_hog),
        .i_data     (i_data_hog),
        .fea        (fea_sig),
        .o_valid    (i_valid_sig)
    );
    svm #(
    .FEA_I        (FEA_I),
    // integer part of hog feature
    .FEA_F        (FEA_F),
    // fractional part of hog feature
    .SW_W         (SW_W)
    // slide window width
) u_svm (
    .clk          (clk),
    .rst          (rst),
    // ram interface
    .addr_a       (addr_a),
    .write_en     (write_en),
    .i_data       (i_data_a),
    .o_data_a     (o_data_a),
    // bias
    .bias         (bias),
    .b_load       (b_load),
    // hog interface
    .i_valid      (i_valid_sig),
    .fea          (fea_sig),
    // output info
    .o_valid      (o_valid),
    .is_person    (is_person),
`ifdef SIM
    .result       (result),
`endif
    // slide window index
    .sw_id        (sw_id)
);
endmodule
