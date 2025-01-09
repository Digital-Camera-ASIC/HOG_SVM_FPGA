
module mag_cal #(
    parameter   PIX_W = 8, // pixel width
    parameter   MAG_F = 4,// fraction part of magnitude
    parameter   TAN_I = 4, // tan integer (signed number)
    parameter   TAN_F = 8, // tan fraction
    localparam  MAG_I = PIX_W + 1, // integer part of magnitude
    localparam  MAG_W = MAG_I + MAG_F,
    localparam  TAN_W = TAN_I + TAN_F
) (
    input                           clk,
    input                           rst,
    input                           i_valid,
    input   [PIX_W * 4 - 1  : 0]    pixel,
    output  [MAG_W - 1      : 0]    magnitude,
    output  [TAN_W - 1      : 0]    tan,
    output                          o_valid
);
    wire signed [PIX_W - 1 : 0] top;
    wire signed [PIX_W - 1 : 0] bot;
    wire signed [PIX_W - 1 : 0] left;
    wire signed [PIX_W - 1 : 0] right;

    wire [PIX_W : 0] ver_diff;
    wire [PIX_W : 0] hor_diff;
    wire [2 * PIX_W : 0] result;
    
    assign {top, bot, left, right} = pixel;
    
    // *_diff valid after 1 cycle
    // result valid after 3 cycles
    sum_sq_diff #(
        .PIX_W       (PIX_W)
    ) u_sum_sq_diff (
        .clk         (clk),
        .top         (top),
        .bot         (bot),
        .left        (left),
        .right       (right),
        .ver_diff    (ver_diff),
        // the difference of vertical (bot - top)
        .hor_diff    (hor_diff),
        // the difference of horizon (right - left)
        .result      (result)
    );

    // magnitude valid after 13 cycles --> from pixel to mag costs 16 cycles
    localparam pi_cycles = 16; // total pipeline cycles
    localparam pi_remain = pi_cycles - 2;
    wire [TAN_W - 1 : 0] tan_w;
    reg [TAN_W - 1 : 0] tan_r [0 : pi_remain - 1];
    reg valid_r [0 : pi_cycles - 1];
    sqrt #(
        .IN_W     (2 * PIX_W + 1),
        .OUT_F    (MAG_F)
    ) u_sqrt (
        .clk      (clk),
        .in       (result),
        .out      (magnitude)
    );

    div #(
        .A_W      (PIX_W + 1),
        .B_W      (PIX_W + 1),
        .O_I_W    (TAN_I),
        // output integer width
        .O_F_W    (TAN_F)
        // output fraction width
    ) u_div (
        .clk      (clk),
        .a        (hor_diff),
        .b        (ver_diff),
        .o        (tan_w)
    );
    integer i;
    always @(posedge clk) begin
        tan_r[0] <= tan_w;
        for(i = 1; i <= pi_remain - 1; i = i + 1)
            tan_r[i] <= tan_r[i - 1];
    end

    always @(posedge clk) begin
        if(!rst) begin
            for(i = 0; i <= pi_cycles - 1; i = i + 1)
                valid_r[i] <= 0;
        end else begin
            valid_r[0] <= i_valid;
            for(i = 1; i <= pi_cycles - 1; i = i + 1)
                valid_r[i] <= valid_r[i - 1];
        end
    end
    assign o_valid = valid_r[pi_cycles - 1];
    assign tan = tan_r[pi_remain - 1];
endmodule
