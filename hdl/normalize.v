module normalize #(
    parameter BIN_I =   16, // integer part of bin
    parameter BIN_F =   16, // fractional part of bin
    parameter BID_W =   13, // block id width
    parameter FEA_I =   4, // integer part of hog feature
    parameter FEA_F =   28 // fractional part of hog feature
) (
    input                                   clk,
    input                                   rst,
    input   [9 * (BIN_I + BIN_F) - 1 : 0]   bin_a,
    input   [9 * (BIN_I + BIN_F) - 1 : 0]   bin_b,
    input   [9 * (BIN_I + BIN_F) - 1 : 0]   bin_c,
    input   [9 * (BIN_I + BIN_F) - 1 : 0]   bin_d,
    input                                   i_valid,
    input                                   clear,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_a,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_b,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_c,
    output  [9 * (FEA_I + FEA_F) - 1 : 0]   fea_d,
    output  [BID_W - 1 : 0]                 bid,
    output                                  o_valid
);
    localparam max_bid = 4660;
    reg     [BID_W - 1 : 0] cnt;
    wire    [BID_W - 1 : 0] n_cnt;
    // bin mapping
    // bin_a: 8 to 0
    // bin b: 17 to 9
    // bin c: 26 to 18
    // bin d: 35 to 27
    wire    [BIN_I + BIN_F - 1 : 0] bin[0 : 35];
    wire    [FEA_I + FEA_F - 1 : 0] quotient[0 : 35];
    wire    [FEA_I + FEA_F - 1 : 0] sqrt_out[0 : 35];
    reg     [BIN_I + BIN_F + 2 - 1 : 0] sum;
    genvar j;

    generate
        for(j = 0; j < 9; j = j + 1) begin
            assign bin[j] = bin_a[(j + 1) * (BIN_I + BIN_F) - 1 : j * (BIN_I + BIN_F)];
            assign bin[j + 9] = bin_b[(j + 1) * (BIN_I + BIN_F) - 1 : j * (BIN_I + BIN_F)];
            assign bin[j + 18] = bin_c[(j + 1) * (BIN_I + BIN_F) - 1 : j * (BIN_I + BIN_F)];
            assign bin[j + 27] = bin_d[(j + 1) * (BIN_I + BIN_F) - 1 : j * (BIN_I + BIN_F)];
        end
    endgenerate
    
    // sum all bins
    // pipeline this (if need)
    integer i;
    always @(*) begin
        for(i = 0; i < 36; i = i+1) begin
            if(i == 0) sum = bin[0];
            else sum = sum + bin[i];
        end
    end

    // divide bin with sum and then sqrt
    
    generate
        for(j = 0; j < 36; j = j + 1) begin
            fxp_div #(
                .WIIA        (BIN_I + 1),
                .WIFA        (BIN_F),
                .WIIB        (BIN_I + 2 + 1),
                .WIFB        (BIN_F),
                .WOI         (FEA_I + 1),
                .WOF         (FEA_F)
            ) u_fxp_div (
                .dividend    ({1'b0, bin[j]}),
                .divisor     ({1'b0, sum}),
                .out         (quotient[j])
            );
            fxp_sqrt #(
                .WII         (FEA_I + 1),
                .WIF         (FEA_F),
                .WOI         (FEA_I + 1),
                .WOF         (FEA_F)
            ) u_fxp_sqrt (
                .in          ({1'b0,quotient[j]}),
                .out         (sqrt_out[j])
            );
        end
    endgenerate


    // output
    assign fea_a = {
        sqrt_out[8], sqrt_out[7], sqrt_out[6], 
        sqrt_out[5], sqrt_out[4], sqrt_out[3], 
        sqrt_out[2], sqrt_out[1], sqrt_out[0]
        };
    assign fea_b = {
        sqrt_out[17], sqrt_out[16], sqrt_out[15], 
        sqrt_out[14], sqrt_out[13], sqrt_out[12], 
        sqrt_out[11], sqrt_out[10], sqrt_out[9]
        };
    assign fea_c = {
        sqrt_out[26], sqrt_out[25], sqrt_out[24], 
        sqrt_out[23], sqrt_out[22], sqrt_out[21],
        sqrt_out[20], sqrt_out[19], sqrt_out[18]
        };
    assign fea_d = {
        sqrt_out[35], sqrt_out[34], sqrt_out[33], 
        sqrt_out[32], sqrt_out[31], sqrt_out[30], 
        sqrt_out[29], sqrt_out[28], sqrt_out[27]};

    assign o_valid = i_valid;
    assign bid = cnt;
    //---------------------

    assign n_cnt =
        (cnt == 4660 || clear) ? {BID_W{1'b0}} :
        (i_valid) ? cnt + 1'b1 : cnt;

    always @(posedge clk) begin
        if(!rst) cnt <= {BID_W{1'b0}};
        else cnt <= n_cnt;
    end
endmodule