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
    localpara COE_N = 7 * 15 * 36; // the number of svm coefficent
    reg [COE_W - 1 : 0] svm_coe [0 : COE_N - 1];
    
    integer i;
    // for sim
    initial begin
        //$read_mem();
        for(i = 0; i < COE_N; i = i + 1)
            svm_coe[i] <= i;
    end

    genvar i;
    generate
        for(i = 0; i < 7; i = i + 1)
    endgenerate
    
endmodule