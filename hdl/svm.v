
// svm human detection
module svm #(
    parameter   FEA_I   = 4, // integer part of hog feature
    parameter   FEA_F   = 8, // fractional part of hog feature
    parameter   SW_W    = 11, // slide window width
    localparam  FEA_W   = FEA_I + FEA_F,
    localparam  COEF_W  = FEA_W,
    localparam  ROW     = 15,
    localparam  COL     = 7,
    localparam  N_COEF  = ROW * COL, // number of coef in a fetch instruction
    localparam  RAM_DW  = COEF_W * N_COEF,
    localparam  ADDR_W  = 6 // ceil of log2(36)
) (
    input                       clk,
    input                       rst,
    // ram interface
    input   [ADDR_W - 1 : 0]    addr_a,
    input                       write_en,
    input   [RAM_DW - 1 : 0]    i_data,
    output  [RAM_DW - 1 : 0]    o_data_a,
    // bias
    input   [COEF_W - 1 : 0]    bias,
    input                       b_load,
    // hog interface
    input                       i_valid,
    input   [FEA_W - 1  : 0]    fea,
    // output info
    output reg                  o_valid,
    output                      is_person,
    output  [FEA_W - 1  : 0]    result,
    output reg [SW_W - 1   : 0] sw_id // slide window index
);

    localparam N_BUF = ROW - 1;
    
    localparam BUF_DEPTH = 33;
    wire o_valid_w;
    wire [SW_W - 1   : 0] sw_id_w;
    always @(posedge clk) begin
        sw_id <= sw_id_w;
        if(~rst)
            o_valid <= 0;
        else
            o_valid <= o_valid_w;
    end
    wire [RAM_DW - 1 : 0] o_data_b;
    wire [ADDR_W - 1 : 0] addr_b;
    wire [COEF_W - 1 : 0] coef [0 : N_COEF - 1];
    reg [COEF_W - 1 : 0] bias_r;
    always @(posedge clk) begin
        if(~rst) 
            bias_r <= 0;
        else if(b_load)
            bias_r <= bias;
    end
    dp_ram2 #(
        .DATA_W      (RAM_DW),
        .ADDR_W      (ADDR_W)
    ) u_dp_ram2 (
        .clk         (clk),
        .addr_a      (addr_a),
        .write_en    (write_en),
        .i_data      (i_data),
        .o_data_a    (o_data_a),
        .addr_b      (addr_b),
        .o_data_b    (o_data_b)
    );
    genvar i;
    generate
        for(i = 0; i < N_COEF; i = i + 1) begin
            assign coef[i] = o_data_b[COEF_W * i +: COEF_W];
        end
    endgenerate
    wire init;
    wire accumulate;
    wire valid_buf;
    svm_ctrl #(
        .SW_W          (SW_W),
        // slide window width, ceil of log2(1200)
        .ADDR_W        (ADDR_W)
        // ceil of log2(36)
    ) u_svm_ctrl (
        .clk           (clk),
        .rst           (rst),
        .i_valid       (i_valid),
        // control ram
        .addr_b        (addr_b),
        // control PE
        .init          (init),
        .accumulate    (accumulate),
        // control buffer
        .valid_buf     (valid_buf),
        // output info
        .sw_id         (sw_id_w),
        // slide window index
        .o_valid       (o_valid_w)
    );
    wire [FEA_W - 1 : 0] o_data[0 : N_COEF - 1];
    wire [FEA_W - 1 : 0] o_data_buf [0 : N_BUF - 1];

    // svm pe 0
    svm_pe #(
        .FEA_I         (FEA_I),
        // integer part of hog feature
        .FEA_F         (FEA_F)
        // fractional part of hog feature
    ) u_svm_pe_0 (
        .clk           (clk),
        .init          (init),
        .accumulate    (accumulate),
        .fea           (fea),
        .coef          (coef[0]),
        .i_data        (bias_r),
        .o_data        (o_data[0])
    );
    generate
        // svm middle 1 2 ...
        for(i = 1; i <= N_COEF - 2; i = ((i + 2) % COL == 0) ? i + 2 : i + 1) begin
            svm_pe #(
                .FEA_I         (FEA_I),
                // integer part of hog feature
                .FEA_F         (FEA_F)
                // fractional part of hog feature
            ) u_svm_pe (
                .clk           (clk),
                .init          (init),
                .accumulate    (accumulate),
                .fea           (fea),
                .coef          (coef[i]),
                .i_data        (o_data[i - 1]),
                .o_data        (o_data[i])
            );
        end

        // svm need store in buf: 6, 13, ..., 97
        for(i = COL - 1; i < N_COEF - COL; i = i + COL) begin
            svm_pe #(
                .FEA_I         (FEA_I),
                // integer part of hog feature
                .FEA_F         (FEA_F)
                // fractional part of hog feature
            ) u_svm_pe (
                .clk           (clk),
                .init          (init),
                .accumulate    (accumulate),
                .fea           (fea),
                .coef          (coef[i]),
                .i_data        (o_data[i - 1]),
                .o_data        (o_data_buf[(i - (COL - 1)) / COL])
            );
        end
        // 14 buffers
        for(i = 0; i < N_BUF; i = i + 1) begin
            buffer #(
                .DATA_W     (FEA_W),
                .DEPTH      (BUF_DEPTH)
            ) u_buffer (
                .clk        (clk),
                // the clock
                .rst        (rst),
                // reset signal
                .i_data     (o_data_buf[i]),
                // input data
                .clear      (1'b0),
                // clear counter
                .i_valid    (valid_buf),
                // input valid signal
                .o_data     (o_data[COL * (i + 1) - 1]),
                // output data
                .o_valid    ()
                // output valid
            );
        end
    endgenerate
    // svm pe 104
    svm_pe #(
        .FEA_I         (FEA_I),
        // integer part of hog feature
        .FEA_F         (FEA_F)
        // fractional part of hog feature
    ) u_svm_pe_104 (
        .clk           (clk),
        .init          (init),
        .accumulate    (accumulate),
        .fea           (fea),
        .coef          (coef[N_COEF - 1]),
        .i_data        (o_data[N_COEF - 2]),
        .o_data        (o_data[N_COEF - 1])
    );

    assign is_person = ~o_data[N_COEF - 1][FEA_W - 1];
    assign result = o_data[N_COEF - 1];
endmodule
