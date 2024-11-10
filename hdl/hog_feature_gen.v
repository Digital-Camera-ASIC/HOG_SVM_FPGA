module hog_feature_gen #(
    parameter ADDR_W =  11, // address width of cells
    parameter BIN_I =   16, // integer part of bin
    parameter BIN_F =   16, // fractional part of bin
    parameter FEA_I =   4, // integer part of hog feature
    parameter FEA_F =   28 // fractional part of hog feature

) (
    input                                   clk,
    input                                   rst,
    input   [ADDR_W - 1 : 0]                addr_fw,
    input                                   valid_fw,
    input   [ADDR_W - 1 : 0]                address,
    input   [9 * (BIN_I + BIN_F) - 1 : 0]   bin,
    input                                   i_valid,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_a,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_b,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_c,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_d,
    output                                  o_valid
);
    
    localparam p_data_w = 18 * (BIN_I + BIN_F);
    localparam buf_depth = 40;

    reg  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_a_r;
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_b_r;
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_c_r;
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_d_r;
    reg                                  o_valid_r;

    wire  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_a_w;
    wire  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_b_w;
    wire  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_c_w;
    wire  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_d_w;
    wire                                  o_valid_w;

    wire clear;
    wire [p_data_w - 1 : 0] p_data;// parallel data
    wire p_valid;// parallel valid
    wire [9 * (BIN_I + BIN_F) - 1 : 0] bin_a; // one line data output
    wire [9 * (BIN_I + BIN_F) - 1 : 0] bin_b; // one line data output
    wire [9 * (BIN_I + BIN_F) - 1 : 0] bin_c; // parallel data output
    wire [9 * (BIN_I + BIN_F) - 1 : 0] bin_d; // parallel data output
    wire ol_valid; // one line valid output

    wire i_valid_nor;

    reg is_addr_valid_r;

    wire i_valid_b;
    assign i_valid_nor = i_valid_b & ol_valid;
    assign clear = !(|addr_fw) & valid_fw; // addr_fw == 0
    
    always @(posedge clk) begin
        if(!rst) is_addr_valid_r <= 1'b0;
        else is_addr_valid_r <= (address % buf_depth) != 0;
    end
    assign i_valid_b = is_addr_valid_r & p_valid;
    serial_to_parallel #(
        .DATA_W     (9 * (BIN_I + BIN_F))
    ) u_serial_to_parallel (
        .clk        (clk),
        .rst        (rst),
        .i_data     (bin),
        .i_valid    (i_valid),
        .clear      (clear),
        .o_data     (p_data),
        .o_valid    (p_valid)
    );

    buffer #(
        .DATA_W     (p_data_w),
        .DEPTH      (buf_depth - 1)
    ) one_line_buffer (
        .clk        (clk),
        // the clock
        .rst        (rst),
        // reset signal
        .i_data     (p_data),
        // input data
        .clear      (clear),
        // clear counter
        .i_valid    (i_valid_b),
        // input valid signal
        .o_data     ({bin_a, bin_b}),
        // output data
        // output valid
        .o_valid    (ol_valid)
    );
    assign {bin_c, bin_d} = p_data;

    normalize #(
        .BIN_I      (BIN_I),
        // integer part of bin
        .BIN_F      (BIN_F),
        // fractional part of bin
        .FEA_I      (FEA_I),
        // integer part of hog feature
        // fractional part of hog feature
        .FEA_F      (FEA_F)
    ) u_normalize (
        .bin_a      (bin_a),
        .bin_b      (bin_b),
        .bin_c      (bin_c),
        .bin_d      (bin_d),
        .i_valid    (i_valid_nor),
        .fea_a      (fea_a_w),
        .fea_b      (fea_b_w),
        .fea_c      (fea_c_w),
        .fea_d      (fea_d_w),
        .o_valid    (o_valid_w)
    );

    // for pipeline system
    always @(posedge clk) begin
        if(!rst) begin
            fea_a_r <= 0;
            fea_b_r <= 0;
            fea_c_r <= 0;
            fea_d_r <= 0;
            o_valid_r <= 0;
        end else begin
            fea_a_r <= fea_a_w;
            fea_b_r <= fea_b_w;
            fea_c_r <= fea_c_w;
            fea_d_r <= fea_d_w;
            o_valid_r <= o_valid_w;
        end
    end
    // output
    assign fea_a = fea_a_r;
    assign fea_b = fea_b_r;
    assign fea_c = fea_c_r;
    assign fea_d = fea_d_r;
    assign o_valid = o_valid_r;
endmodule