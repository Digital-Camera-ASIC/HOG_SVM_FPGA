module mag_cal #(
    parameter PIX_W = 8, // pixel width
    parameter MAG_I = 9, // integer part of magnitude
    parameter MAG_F = 16,// fraction part of magnitude
    parameter TAN_W = 19 // tan width
) (
    input   [PIX_W * 4 - 1 : 0]     pixel,
    output  [MAG_I + MAG_F - 1 : 0] magnitude,
    output  [TAN_W - 1 : 0]         tan,
    output                          negative
);
    localparam sum_w = PIX_W * 2 + 1;
    wire [PIX_W - 1 : 0] top;
    wire [PIX_W - 1 : 0] bottom;
    wire [PIX_W - 1 : 0] left;
    wire [PIX_W - 1 : 0] right;
    wire [PIX_W - 1 : 0] max_x;
    wire [PIX_W - 1 : 0] min_x;
    wire [PIX_W - 1 : 0] max_y;
    wire [PIX_W - 1 : 0] min_y;
    wire negative_x;
    wire negative_y;
    wire [PIX_W - 1 : 0] mag_x;
    wire [PIX_W - 1 : 0] mag_y;
    wire [sum_w - 1 : 0] sum_of_square;
    //pixel order: {top, bottom, left right}
    assign {top, bottom, left, right} = pixel;
    assign {negative_y, max_y, min_y} = 
        (bottom < top) ? {1'b1, top, bottom} : {1'b0, bottom, top};
    assign {negative_x, max_x, min_x} = 
        (right < left) ? {1'b1, left, right} : {1'b0, right, left};
    
    assign mag_x = max_x - min_x;
    assign mag_y = max_y - min_y;


    assign sum_of_square = mag_x**2 + mag_y**2;

    assign negative = negative_x ^ negative_y;

    fxp_div #(
        .WIIA        (PIX_W + 1),
        .WIFA        (0),
        .WIIB        (PIX_W + 1),
        .WIFB        (0),
        .WOI         (TAN_W - 16),
        .WOF         (16)
    ) u_fxp_div (
        .dividend    ({1'b0, mag_y}),
        .divisor     ({1'b0, mag_x}),
        .out         (tan)
    );

    fxp_sqrt #(
        .WII         (sum_w + 1),
        .WIF         (0),
        .WOI         (MAG_I + 1),
        .WOF         (MAG_F)
    ) u_fxp_sqrt (
        .in          ({1'b0, sum_of_square}),
        .out         (magnitude)
    );
endmodule