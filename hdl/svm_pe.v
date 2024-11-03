// support vector machine parallel element
module svm_pe #(
    parameter FEA_I =   4, // integer part of hog feature
    parameter FEA_F =   28 // fractional part of hog feature
) (
    input                                       clk,
    input                                       rst,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       fea_a,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       fea_b,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       fea_c,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       fea_d,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       coef_a,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       coef_b,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       coef_c,
    input   [9 * (FEA_I + FEA_F) - 1 : 0]       coef_d,
    input   [(FEA_I + FEA_F) - 1 : 0]           i_data,
    input                                       i_valid,
    output reg [(FEA_I + FEA_F) - 1 : 0]        o_data
);
    localpara FEA_N = FEA_I + FEA_F;

    wire [FEA_N - 1 : 0] product [0 : 35];
    reg [FEA_N - 1 : 0] sum_of_product;
    
    genvar i;
    generate
        for(i = 0; i < 9; i = i + 1) begin
            assign product[i] = fea_a[(i + 1) * FEA_N - 1 : i * FEA_N] * coef_a[(i + 1) * FEA_N - 1 : i * FEA_N];
        end
        for(i = 10; i < 18; i = i + 1) begin
            assign product[i] = fea_b[(i - 10 + 1) * FEA_N - 1 : i * FEA_N] * coef_b[(i - 10 + 1) * FEA_N - 1 : i * FEA_N];
        end
        for(i = 19; i < 27; i = i + 1) begin
            assign product[i] = fea_c[(i - 19 + 1) * FEA_N - 1 : i * FEA_N] * coef_c[(i - 19 + 1) * FEA_N - 1 : i * FEA_N];
        end
        for(i = 28; i < 36; i = i + 1) begin
            assign product[i] = fea_d[(i - 28 + 1) * FEA_N - 1 : i * FEA_N] * coef_d[(i - 28 + 1) * FEA_N - 1 : i * FEA_N];
        end
    endgenerate

    integer id;
    always @(*) begin
        for(id = 0; id < 36; id = id+1) begin
            if(id == 0) sum_of_product = i_data + product[id];
            else sum_of_product = sum_of_product + product[id];
        end
    end

    always @(posedge clk) begin
        if(!rst) o_data <= 0;
        else o_data <= sum_of_product;
    end
endmodule