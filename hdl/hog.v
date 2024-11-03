module hog #(
    parameter PIX_W = 8, // pixel width
    parameter PIX_N = 96, // the number of pixels
    parameter MAG_I = 9, // integer part of magnitude
    parameter MAG_F = 16,// fraction part of magnitude
    parameter TAN_W = 19, // tan width
    parameter BIN_I =   16, // integer part of bin
    parameter BIN_F =   16, // fractional part of bin
    parameter ADDR_W =  11, // address width of cells
    parameter BID_W =   13, // block id width
    parameter FEA_I =   4, // integer part of hog feature
    parameter FEA_F =   28 // fractional part of hog feature
) (
    input                                       clk,
    input                                       rst,
    input                                       ready,
    input   [PIX_W * PIX_N - 1 : 0]             i_data,
    output                                      request,
    output  [BID_W - 1 : 0]                     bid,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_a,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_b,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_c,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_d,
    output                                      o_valid
);
    wire                                  o_valid_sig;
    wire [ADDR_W - 1 : 0]                 addr_fw_sig;
    wire [ADDR_W - 1 : 0]                 address_sig;
    wire [9 * (BIN_I + BIN_F) - 1 : 0]    bin_sig;

    hog_fetch #(
        .ADDR_W     (ADDR_W),
        .PIX_W      (PIX_W),
        // pixel width
        .PIX_N      (PIX_N),
        .MAG_I      (MAG_I),
        // integer part of magnitude
        .MAG_F      (MAG_F),
        // fraction part of magnitude
        .TAN_W      (TAN_W),
        // tan width
        .BIN_I      (BIN_I),
        // integer part of bin
        // fractional part of bin
        .BIN_F      (BIN_F)
    ) u_hog_fetch (
        .clk        (clk),
        .rst        (rst),
        .ready      (ready),
        .i_data     (i_data),
        .request    (request),
        .o_valid    (o_valid_sig),
        .addr_fw    (addr_fw_sig),
        .address    (address_sig),
        .bin        (bin_sig)
    );

    hog_feature_gen #(
        .ADDR_W     (ADDR_W),
        // address width of cells
        .BIN_I      (BIN_I),
        // integer part of bin
        .BIN_F      (BIN_F),
        // fractional part of bin
        .BID_W      (BID_W),
        // block id width
        .FEA_I      (FEA_I),
        // integer part of hog feature
        // fractional part of hog feature

        .FEA_F      (FEA_F)
    ) u_hog_feature_gen (
        .clk        (clk),
        .rst        (rst),
        .addr_fw    (addr_fw_sig),
        .address    (address_sig),
        .bin        (bin_sig),
        .i_valid    (o_valid_sig),
        .bid        (bid),
        .fea_a      (fea_a),
        .fea_b      (fea_b),
        .fea_c      (fea_c),
        .fea_d      (fea_d),
        .o_valid    (o_valid)
    );
endmodule