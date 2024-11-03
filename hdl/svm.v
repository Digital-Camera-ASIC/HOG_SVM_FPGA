module svm #(
    parameter FEA_I =   4, // integer part of hog feature
    parameter FEA_F =   28, // fractional part of hog feature
    parameter BID_W =   13, // block id width
) (
    input                                       clk,
    input                                       rst,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_a,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_b,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_c,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]       fea_d,
    input                                      i_valid
);
    localpara COE_I = FEA_I; // integer part of svm coefficent
    localpara COE_F = FEA_F; // fractional part of svm coefficent
    localpara COE_W = COE_I + COE_F;
    localpara COE_N = 7 * 15 * 4; // the number of svm coefficent
    reg [COE_W * 9 - 1 : 0] svm_coef [0 : COE_N - 1];
    
    wire [COE_W - 1 : 0] o_data [0 : 7 * 15 - 1];
    integer i;
    // for sim
    initial begin
        //$read_mem();
        for(i = 0; i < COE_N; i = i + 1)
            svm_coef[i] <= i;
    end
    svm_pe #(
        .FEA_I      (FEA_I),
        // integer part of hog feature
        .FEA_F      (FEA_F)
        // fractional part of hog feature
    ) u_svm_pe (
        .clk        (clk),
        .rst        (rst),
        .fea_a      (fea_a),
        .fea_b      (fea_b),
        .fea_c      (fea_c),
        .fea_d      (fea_d),
        .coef_a     (svm_coef[0]),
        .coef_b     (svm_coef[1]),
        .coef_c     (svm_coef[2]),
        .coef_d     (svm_coef[3]),
        .i_data     ({COE_W{1'b0}}),
        .i_valid    (i_valid),
        .o_data     (o_data)
    );
    genvar i;
    generate
        for(i = 0; i < 7; i = i + 1)begin
            svm_pe #(
                .FEA_I      (FEA_I),
                // integer part of hog feature
                .FEA_F      (FEA_F)
                // fractional part of hog feature
            ) u_svm_pe (
                .clk        (clk),
                .rst        (rst),
                .fea_a      (fea_a),
                .fea_b      (fea_b),
                .fea_c      (fea_c),
                .fea_d      (fea_d),
                .coef_a     (svm_coef[i]),
                .coef_b     (svm_coef),
                .coef_c     (svm_coef),
                .coef_d     (svm_coef),
                .i_data     (i_data),
                .i_valid    (i_valid),
                .o_data     (o_data)
            );
        end
    endgenerate
    
endmodule