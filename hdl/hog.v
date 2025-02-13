module hog #(
    parameter   PIX_W   = 8, // pixel width
    parameter   MAG_F   = 4,// fraction part of magnitude
    parameter   TAN_I   = 4, // tan width
    parameter   TAN_F   = 16, // tan width
    parameter   BIN_I   = 16, // integer part of bin
    parameter   FEA_I   = 4, // integer part of hog feature
    parameter   FEA_F   = 8, // fractional part of hog feature
    localparam  FEA_W   = FEA_I + FEA_F,
    localparam  IN_W    = PIX_W * 4
) (
    input                       clk,
    input                       rst,
    input                       i_valid,
    input   [IN_W - 1   : 0]    i_data,
    output  [FEA_W - 1  : 0]    fea,
    output                      o_valid
);
    localparam TAN_W = TAN_I + TAN_F;
    localparam MAG_I = PIX_W + 1;
    localparam BIN_F = MAG_F;
    localparam MAG_W = MAG_I + MAG_F;
    localparam BIN_W = BIN_I + BIN_F;
    wire [MAG_W - 1 : 0] magnitude;
    wire [TAN_W - 1 : 0] tan;
    wire [BIN_W * 9 - 1 : 0] bin;
    wire mag_cal_valid;
    wire bin_cal_valid;
    mag_cal #(
        .PIX_W        (PIX_W),
        // pixel width
        .MAG_F        (MAG_F),
        // fraction part of magnitude
        .TAN_I        (TAN_I),
        // tan integer (signed number)
        .TAN_F        (TAN_F)
        // tan fraction
    ) u_mag_cal (
        .clk          (clk),
        .rst          (rst),
        .i_valid      (i_valid),
        .pixel        (i_data),
        .magnitude    (magnitude),
        .tan          (tan),
        .o_valid      (mag_cal_valid)
    );
    bin_cal #(
        .TAN_W        (TAN_W),
        .MAG_I        (MAG_I),
        .MAG_F        (MAG_F),
        .BIN_I        (BIN_I)
        // integer part of bin
    ) u_bin_cal (
        .clk          (clk),
        .rst          (rst),
        .i_valid      (mag_cal_valid),
        .magnitude    (magnitude),
        .tan          (tan),
        .o_valid      (bin_cal_valid),
        .bin          (bin)
    );
    normalize #(
        .BIN_I      (BIN_I),
        // integer part of bin
        .BIN_F      (BIN_F),
        // fractional part of bin
        .FEA_I      (FEA_I),
        // integer part of hog feature
        .FEA_F      (FEA_F)
        // fractional part of hog feature
    ) u_normalize (
        .clk        (clk),
        .rst        (rst),
        .bin        (bin),
        .i_valid    (bin_cal_valid),
        .fea        (fea),
        .o_valid    (o_valid)
    );
endmodule
