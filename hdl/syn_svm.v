module syn_svm #(
    parameter FEA_I = 4, // integer part of hog feature
    parameter FEA_F = 28, // fractional part of hog feature
    parameter SW_W  = 11 // slide window width
)(
    input                                       clk,
    input                                       rst,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_a,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_b,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_c,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_d,
    input                                       i_valid,
    output reg                                     is_person,
    output reg                                     o_valid,
    output reg[(FEA_I + FEA_F) - 1 : 0]            result,
    output reg[SW_W - 1 : 0]                       sw_id // slide window index
);
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_a_syn;
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_b_syn;
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_c_syn;
    reg  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_d_syn;
    reg                                       i_valid_syn;
    wire                                      is_person_syn;
    wire                                      o_valid_syn;
    wire [(FEA_I + FEA_F) - 1 : 0]            result_syn;
    wire [SW_W - 1 : 0]                       sw_id_syn;
    always @(posedge clk) begin
        if(!rst)begin
            fea_a_syn <= 0;
            fea_b_syn <= 0;
            fea_c_syn <= 0;
            fea_d_syn <= 0;
            i_valid_syn <= 0;
            is_person <= 0;
            o_valid <= 0;
            result <= 0;
            sw_id <= 0;
        end else begin
            fea_a_syn <= fea_a;
            fea_b_syn <= fea_b;
            fea_c_syn <= fea_c;
            fea_d_syn <= fea_d;
            i_valid_syn <= i_valid;
            is_person <= is_person_syn;
            o_valid <= o_valid_syn;
            result <= result_syn;
            sw_id <= sw_id_syn;
        end
        
    end
    svm #(
    .FEA_I        (4),
    // integer part of hog feature
    .FEA_F        (28),
    // fractional part of hog feature
    // slide window width
    .SW_W         (11)
) u_svm (
    .clk          (clk),
    .rst          (rst),
    .fea_a        (fea_a_syn),
    .fea_b        (fea_b_syn),
    .fea_c        (fea_c_syn),
    .fea_d        (fea_d_syn),
    .i_valid      (i_valid_syn),
    .is_person    (is_person_syn),
    .o_valid      (o_valid_syn),
    .result       (result_syn),
    // slide window index
    .sw_id        (sw_id_syn)
);
endmodule