
module mag_cal_sbs #(
    parameter PIX_W = 8, // pixel width
    parameter MAG_I = 9, // integer part of magnitude
    parameter MAG_F = 16,// fraction part of magnitude
    parameter TAN_W = 19 // tan width
) (
    input                           clk,
    input                           rst,
    input   [PIX_W * 4 - 1 : 0]     pixel,
    output  [MAG_I + MAG_F - 1 : 0] bin0,
    output  [MAG_I + MAG_F - 1 : 0] bin20,
    output  [MAG_I + MAG_F - 1 : 0] bin40,
    output  [MAG_I + MAG_F - 1 : 0] bin60,
    output  [MAG_I + MAG_F - 1 : 0] bin80,
    output  [MAG_I + MAG_F - 1 : 0] bin100,
    output  [MAG_I + MAG_F - 1 : 0] bin120,
    output  [MAG_I + MAG_F - 1 : 0] bin140,
    output  [MAG_I + MAG_F - 1 : 0] bin160
);
    localparam pipe_cycle = 1;
    wire   [TAN_W - 1 : 0]         tan_n;
    wire                           negative_n;
    wire   [MAG_I + MAG_F - 1 : 0] magnitude_n;
    reg   [TAN_W - 1 : 0]         tan_r;
    reg                           negative_r;
    reg   [MAG_I + MAG_F - 1 : 0] magnitude_r;
    
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
        .bin0         (bin0),
        .bin20        (bin20),
        .bin40        (bin40),
        .bin60        (bin60),
        .bin80        (bin80),
        .bin100       (bin100),
        .bin120       (bin120),
        .bin140       (bin140),
        .bin160       (bin160)
    );
    
endmodule