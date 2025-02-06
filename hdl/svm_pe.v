// support vector machine parallel element
module svm_pe #(
    parameter   FEA_I   = 4, // integer part of hog feature
    parameter   FEA_F   = 8, // fractional part of hog feature
    localparam  FEA_W   = FEA_I + FEA_F,
    localparam  COEF_W  = FEA_W
) (
    input                               clk,
    input                               init,
    input                               accumulate,
    input signed    [FEA_W - 1  : 0]    fea,
    input signed    [COEF_W - 1 : 0]    coef,
    input signed    [FEA_W - 1  : 0]    i_data,
    output reg      [FEA_W - 1  : 0]    o_data
);
    reg signed    [FEA_W - 1  : 0]    fea_r;
    reg signed [FEA_W * 2 - 1  : 0] acc_mult;

    always @(posedge clk) begin
        fea_r <= fea;
        if(init)
            acc_mult <= fea_r * coef;
        else
            acc_mult <= fea_r * coef + acc_mult;
    end
    wire signed [FEA_W - 1  : 0] acc_mult_w;
    assign acc_mult_w = acc_mult[FEA_F +: FEA_W];
    always @(posedge clk) begin
        if(accumulate)
            o_data <= i_data + acc_mult_w;
    end
endmodule
