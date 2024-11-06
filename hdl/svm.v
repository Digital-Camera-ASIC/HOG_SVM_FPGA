// svm human detection
module svm #(
    parameter FEA_I = 4, // integer part of hog feature
    parameter FEA_F = 28, // fractional part of hog feature
    parameter SW_W  = 11 // slide window width
) (
    input                                       clk,
    input                                       rst,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_a,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_b,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_c,
    input  [9 * (FEA_I + FEA_F) - 1 : 0]        fea_d,
    input                                       i_valid,
    output                                      is_person,
    output                                      o_valid,
    output [(FEA_I + FEA_F) - 1 : 0]            result,
    output [SW_W - 1 : 0]                       sw_id // slide window index
);
    localparam COE_I = FEA_I; // integer part of svm coefficent
    localparam COE_F = FEA_F; // fractional part of svm coefficent
    localparam COE_W = COE_I + COE_F;
    localparam COE_N = 7 * 15 * 4; // the number of svm coefficent

    localparam BUF_DEPTH = 32;
    reg [COE_W * 9 - 1 : 0] svm_coef [0 : COE_N - 1];
    
    wire [COE_W - 1 : 0] o_data [0 : 7 * 15 - 1];
    integer id;
    // for sim
    initial begin
        //$read_mem();
        for(id = 0; id < COE_N; id = id + 1)
            svm_coef[id] <= {9{id[31:0]}};
    end
    wire [COE_W - 1 : 0] o_data_b [0:13];
    genvar i;

    // svm pe 0
    svm_pe #(
        .FEA_I      (FEA_I),
        // integer part of hog feature
        .FEA_F      (FEA_F)
        // fractional part of hog feature
    ) u_svm_pe_0 (
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
        .o_data     (o_data[0])
    );
    
    
    generate
        // svm middle 1 2 ...
        for(i = 1; i <= 103; i = ((i + 2) % 7 == 0) ? i + 2 : i + 1) begin
            svm_pe #(
                .FEA_I      (FEA_I),
                // integer part of hog feature
                // fractional part of hog feature
                .FEA_F      (FEA_F)
            ) u_svm_pe (
                .clk        (clk),
                .rst        (rst),
                .fea_a      (fea_a),
                .fea_b      (fea_b),
                .fea_c      (fea_c),
                .fea_d      (fea_d),
                .coef_a     (svm_coef[i*4]),
                .coef_b     (svm_coef[i*4 + 1]),
                .coef_c     (svm_coef[i*4 + 2]),
                .coef_d     (svm_coef[i*4 + 3]),
                .i_data     (o_data[i - 1]),
                .i_valid    (i_valid),
                .o_data     (o_data[i])
            );
        end

        // svm need store in buf: 6, 13, ..., 97
        for(i = 6; i <= 97; i = i + 7) begin
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
                .coef_a     (svm_coef[i*4]),
                .coef_b     (svm_coef[i*4 + 1]),
                .coef_c     (svm_coef[i*4 + 2]),
                .coef_d     (svm_coef[i*4 + 3]),
                .i_data     (o_data[i - 1]),
                .i_valid    (i_valid),
                .o_data     (o_data_b[i/7])
            );
        end
        // 14 buffers
        for(i = 0; i < 14; i = i + 1) begin
            buffer #(
                .DATA_W     (COE_W),
                .DEPTH      (BUF_DEPTH)
            ) u_buffer (
                .clk        (clk),
                // the clock
                .rst        (rst),
                // reset signal
                .i_data     (o_data_b[i]),
                // input data
                .clear      (1'b0),
                // clear counter
                .i_valid    (i_valid),
                // input valid signal
                .o_data     (o_data[i * 7 + 6]),
                // output data
                .o_valid    ()
                // output valid
            );
        end
    endgenerate
    // svm pe 104
    svm_pe #(
        .FEA_I      (FEA_I),
        // integer part of hog feature
        .FEA_F      (FEA_F)
        // fractional part of hog feature
    ) u_svm_pe_104 (
        .clk        (clk),
        .rst        (rst),
        .fea_a      (fea_a),
        .fea_b      (fea_b),
        .fea_c      (fea_c),
        .fea_d      (fea_d),
        .coef_a     (svm_coef[104*4]),
        .coef_b     (svm_coef[104*4 + 1]),
        .coef_c     (svm_coef[104*4 + 2]),
        .coef_d     (svm_coef[104*4 + 3]),
        .i_data     (o_data[103]),
        .i_valid    (i_valid),
        .o_data     (o_data[104])
    );
    svm_ctrl #(
        // slide window width
        .SW_W       (SW_W)
    ) u_svm_ctrl (
        .clk        (clk),
        .rst        (rst),
        .i_valid    (i_valid),
        .o_valid    (o_valid),
        // slide window index
        .sw_id      (sw_id)
    );
    assign is_person = ~o_data[7 * 15 - 1][COE_W - 1];
    assign result = o_data[7 * 15 - 1];
endmodule