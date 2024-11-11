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
    localparam FEA_N = FEA_I + FEA_F;
    
    // 32 bit (4 bit int, 28 bit frac) x 32 bit (4 bit int, 28 bit frac)
    // -> 8 bit int, 56 bit frac [63 : 60] [59 : 56] [55 : 28] [27 : 0]
    // -> need [59 : 28]
    
    // step 1: convert to unsigned
    wire negative [0 : 35];
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_fea_a; // unsigned a
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_fea_b; //
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_fea_c; //
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_fea_d; //
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_coef_a; // unsigned coef a
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_coef_b; // unsigned coef b
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_coef_c; // unsigned coef c
    wire [9 * (FEA_I + FEA_F) - 1 : 0] uns_coef_d; // unsigned coef d
    genvar i;
    generate
        for(i = 0; i < 9; i = i + 1) begin
            assign uns_fea_a[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (fea_a[(i + 1) * FEA_N - 1]) ? ~fea_a[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : fea_a;
            assign uns_fea_b[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (fea_b[(i + 1) * FEA_N - 1]) ? ~fea_b[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : fea_b;
            assign uns_fea_c[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (fea_c[(i + 1) * FEA_N - 1]) ? ~fea_c[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : fea_c;
            assign uns_fea_d[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (fea_d[(i + 1) * FEA_N - 1]) ? ~fea_d[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : fea_d;

            assign uns_coef_a[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (coef_a[(i + 1) * FEA_N - 1]) ? ~coef_a[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : coef_a;
            assign uns_coef_b[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (coef_b[(i + 1) * FEA_N - 1]) ? ~coef_b[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : coef_b;
            assign uns_coef_c[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (coef_c[(i + 1) * FEA_N - 1]) ? ~coef_c[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : coef_c;
            assign uns_coef_d[(i + 1) * FEA_N - 1 : i * FEA_N] = 
                (coef_d[(i + 1) * FEA_N - 1]) ? ~coef_d[(i + 1) * FEA_N - 1 : i * FEA_N] + 1'b1 : coef_d;
            // signed of product
            assign negative[i] = fea_a[(i + 1) * FEA_N - 1] ^ coef_a[(i + 1) * FEA_N - 1];
            assign negative[i + 9] = fea_b[(i + 1) * FEA_N - 1] ^ coef_b[(i + 1) * FEA_N - 1];
            assign negative[i + 18] = fea_c[(i + 1) * FEA_N - 1] ^ coef_c[(i + 1) * FEA_N - 1];
            assign negative[i + 27] = fea_d[(i + 1) * FEA_N - 1] ^ coef_d[(i + 1) * FEA_N - 1];
        end
    endgenerate
    
    // step 2: calculate unsigned product and product
    wire [FEA_N * 2 - 1 : 0] uns_product [0 : 35];
    wire [FEA_N * 2 - 1 : 0] product [0 : 35];
    reg [FEA_N * 2 - 1 : 0] sum_of_product;
    
    
    generate
        for(i = 0; i < 9; i = i + 1) begin
            assign uns_product[i] 
                = uns_fea_a[(i + 1) * FEA_N - 1 : i * FEA_N] * 
                uns_coef_a[(i + 1) * FEA_N - 1 : i * FEA_N];
        end
        for(i = 9; i < 18; i = i + 1) begin
            assign uns_product[i] 
                = uns_fea_b[(i - 9 + 1) * FEA_N - 1 : (i - 9) * FEA_N] * 
                uns_coef_b[(i - 9 + 1) * FEA_N - 1 : (i - 9) * FEA_N];
        end
        for(i = 18; i < 27; i = i + 1) begin
            assign uns_product[i] 
                = uns_fea_c[(i - 18 + 1) * FEA_N - 1 : (i - 18) * FEA_N] * 
                uns_coef_c[(i - 18 + 1) * FEA_N - 1 : (i - 18) * FEA_N];
        end
        for(i = 27; i < 36; i = i + 1) begin
            assign uns_product[i] 
                = uns_fea_d[(i - 27 + 1) * FEA_N - 1 : (i - 27) * FEA_N] * 
                uns_coef_d[(i - 27 + 1) * FEA_N - 1 : (i - 27) * FEA_N];
        end
        for(i = 0; i < 36; i = i + 1) begin
            assign product[i] = (negative[i]) ? ~uns_product[i] + 1'b1 : uns_product[i];
        end
    endgenerate
    // step 3: convert i_data to 64 bit
    wire [FEA_N * 2 - 1 : 0] i_data_64;
    assign i_data_64 = 
        (i_data[FEA_N - 1]) ? {{FEA_I{1'b1}}, i_data, {FEA_F{1'b0}}} :
        {{FEA_I{1'b0}}, i_data, {FEA_F{1'b0}}};
    integer id;
    always @(*) begin
        for(id = 0; id < 36; id = id+1) begin
            if(id == 0) sum_of_product = i_data_64 + product[id];
            else sum_of_product = sum_of_product + product[id];
        end
    end

    always @(posedge clk) begin
        if(!rst) o_data <= 0;
        else if(i_valid) o_data <= sum_of_product[59 : 28];
    end
endmodule