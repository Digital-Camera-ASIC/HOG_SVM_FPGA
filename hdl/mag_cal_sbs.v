
module mag_cal_sbs #(
    parameter PIX_W = 8, // pixel width
    parameter MAG_I = 9, // integer part of magnitude
    parameter MAG_F = 16,// fraction part of magnitude
    parameter TAN_W = 19 // tan width
) (
    input                               clk,
    input                               rst,
    input   [PIX_W * 4 - 1 : 0]         pixel,
    output reg  [MAG_I + MAG_F - 1 : 0] bin0,
    output reg  [MAG_I + MAG_F - 1 : 0] bin20,
    output reg  [MAG_I + MAG_F - 1 : 0] bin40,
    output reg  [MAG_I + MAG_F - 1 : 0] bin60,
    output reg  [MAG_I + MAG_F - 1 : 0] bin80,
    output reg  [MAG_I + MAG_F - 1 : 0] bin100,
    output reg  [MAG_I + MAG_F - 1 : 0] bin120,
    output reg  [MAG_I + MAG_F - 1 : 0] bin140,
    output reg  [MAG_I + MAG_F - 1 : 0] bin160
);
    localparam pipe_cycle = 1;
    wire   [TAN_W - 1 : 0]         tan_n;
    wire                           negative_n;
    wire   [MAG_I + MAG_F - 1 : 0] magnitude_n;
    reg   [TAN_W - 1 : 0]         tan_r;
    reg                           negative_r;
    reg   [MAG_I + MAG_F - 1 : 0] magnitude_r;
    
    wire  [MAG_I + MAG_F - 1 : 0] bin0_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin20_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin40_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin60_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin80_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin100_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin120_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin140_n;
    wire  [MAG_I + MAG_F - 1 : 0] bin160_n;

    mag_cal #(
        .PIX_W        (PIX_W),
        // pixel width
        .MAG_I        (MAG_I),
        // integer part of magnitude
        .MAG_F        (MAG_F),
        // fraction part of magnitude
        // tan width
        .TAN_W        (TAN_W)
    ) u_mag_cal (
        .pixel        (pixel),
        .magnitude    (magnitude_n),
        .tan          (tan_n),
        .negative     (negative_n)
    );

    always @(posedge clk) begin
        if(!rst) begin
            tan_r <= 0;
            magnitude_r <= 0;
            negative_r <= 0;
        end else begin
            tan_r <= tan_n;
            magnitude_r <= magnitude_n;
            negative_r <= negative_n;
        end
    end

    bin_cal #(
        .TAN_W        (TAN_W),
        .MAG_I        (MAG_I),
        .MAG_F        (MAG_F)
    ) u_bin_cal (
        .tan          (tan_r),
        .negative     (negative_r),
        .magnitude    (magnitude_r),
        .bin0         (bin0_n),
        .bin20        (bin20_n),
        .bin40        (bin40_n),
        .bin60        (bin60_n),
        .bin80        (bin80_n),
        .bin100       (bin100_n),
        .bin120       (bin120_n),
        .bin140       (bin140_n),
        .bin160       (bin160_n)
    );
    always @(posedge clk) begin
        if(!rst) begin
            bin0 <= 0;
            bin20 <= 0;
            bin40 <= 0;
            bin60 <= 0;
            bin80 <= 0;
            bin100 <= 0;
            bin120 <= 0;
            bin140 <= 0;
            bin160 <= 0;
        end else begin
            bin0 <= bin0_n;
            bin20 <= bin20_n;
            bin40 <= bin40_n;
            bin60 <= bin60_n;
            bin80 <= bin80_n;
            bin100 <= bin100_n;
            bin120 <= bin120_n;
            bin140 <= bin140_n;
            bin160 <= bin160_n;
        end
    end
endmodule