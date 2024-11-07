module detect_person#(
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
    parameter FEA_F =   28, // fractional part of hog feature
    parameter SW_W  = 11 // slide window width
)(
    input                                       clk,
    input                                       rst,
    input                                       ready,
    input   [PIX_W * PIX_N - 1 : 0]             i_data,
    output                                      request,
    output                                      is_person,
    output                                      o_valid,
    output [(FEA_I + FEA_F) - 1 : 0]            result,
    output [SW_W - 1 : 0]                       sw_id // slide window index
);
    wire [9 * (FEA_I + FEA_F) - 1 : 0]          fea_a_sig;
    wire [9 * (FEA_I + FEA_F) - 1 : 0]          fea_b_sig;
    wire [9 * (FEA_I + FEA_F) - 1 : 0]          fea_c_sig;
    wire [9 * (FEA_I + FEA_F) - 1 : 0]          fea_d_sig;
    wire     i_valid_sig;
    
    hog #(
        .PIX_W      (PIX_W),
        .PIX_N      (PIX_N),
        .MAG_I      (MAG_I),
        .MAG_F      (MAG_F),
        .TAN_W      (TAN_W),
        .BIN_I      (BIN_I),
        .BIN_F      (BIN_F),
        .ADDR_W     (ADDR_W),
        .BID_W      (BID_W),
        .FEA_I      (FEA_I),
        .FEA_F      (FEA_F)
    ) u_hog (
        .clk        (clk),
        .rst        (rst),
        .ready      (ready),
        .i_data     (i_data),
        .request    (request),
        .bid        (sw_id),
        .fea_a      (fea_a_sig),
        .fea_b      (fea_b_sig),
        .fea_c      (fea_c_sig),
        .fea_d      (fea_d_sig),
        .o_valid    (i_valid_sig)
    );

    svm #(
        .FEA_I      (FEA_I),
        .FEA_F      (FEA_F),
        .SW_W       (SW_W)
    ) u_svm (
        .clk        (clk),
        .rst        (rst),
        .fea_a      (fea_a_sig),
        .fea_b      (fea_b_sig),
        .fea_c      (fea_c_sig),
        .fea_d      (fea_d_sig),
        .i_valid    (i_valid_sig),
        .is_person  (is_person),
        .o_valid    (o_valid),
        .result     (result),
        .sw_id      (sw_id)
    );
endmodule