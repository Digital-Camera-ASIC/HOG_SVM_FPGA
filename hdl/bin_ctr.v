module bin_ctr #(
    localparam  TAN_W   = 20,
    localparam  CODE_W  = 4,
    localparam  CNT_W   = 6,
    localparam  MAX_CNT = 64
)(
    input                               clk,
    input                               rst,
    input                               i_valid,
    input signed    [TAN_W - 1  : 0]    tan,
    output          [CODE_W - 1 : 0]    code,
    output reg      [CNT_W - 1  : 0]    cnt,
    output reg                          o_valid
);
    localparam signed tan0 = 20'h0;
    localparam signed tan20 = 20'h5D2D;
    localparam signed tan40 = 20'hD6CF;

    localparam signed tan60 = 20'h1BB68;

    localparam signed tan80 = 20'h5ABD9;
    localparam signed tan100 = 20'hA5427;

    localparam signed tan120 = 20'hE4498;

    localparam signed tan140 = 20'hF2931;
    localparam signed tan160 = 20'hFA2D3;
    // (0 < tan < tan20) → code = 0
    // (tan20 ≤ tan < tan40) → code = 1
    // (tan40 ≤ tan < tan60) → code = 2
    // (tan60 ≤ tan < tan80) → code = 3
    // (tan80 ≤ tan || tan < tan100) → code = 4
    // (tan100 ≤ tan < tan120) → code = 5
    // (tan120 ≤ tan < tan140) → code = 6
    // (tan140 ≤ tan < tan160) → code = 7
    // (tan160 ≤ tan < 0) → code = 8

    always @(posedge clk) begin
        if(!rst) begin
            cnt <= 0;
            o_valid <= 0;
        end else if(i_valid) begin
            cnt <= cnt + 1;
            if(cnt == MAX_CNT - 1)
                o_valid <= 1;
            else
                o_valid <= 0;
        end else
            o_valid <= 0;
    end
    assign code = (tan0 <= tan  && tan < tan20) ? 0 :
        (tan20 <= tan && tan < tan40) ? 1 :
        (tan40 <= tan && tan < tan60) ? 2 :
        (tan60 <= tan && tan < tan80) ? 3 :
        (tan80 <= tan || tan < tan100) ? 4 :
        (tan100 <= tan && tan < tan120) ? 5 :
        (tan120 <= tan && tan < tan140) ? 6 :
        (tan140 <= tan && tan < tan160) ? 7 : 8;
endmodule
