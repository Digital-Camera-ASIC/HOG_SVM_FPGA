module hog_fetch #(
    parameter   PIX_W   = 8,
    parameter   CELL_S  = 10, // Size of cell, default 8x8 pixel and border
    localparam  PIX_N   = CELL_S * CELL_S - 4, // number of cell 
    localparam  IN_W    = PIX_W * PIX_N,
    localparam  OUT_W   = PIX_W * 4 // top, bot, left, right
) (
    input                       clk,
    input                       rst,
    // fifo if
    input                       ready,
    output                      request,
    input   [IN_W - 1   : 0]    i_data,
    // hog if
    output                      i_valid,
    output  [OUT_W - 1  : 0]    o_data // top, bot left, right
);
    reg [5 : 0] cnt; // log2(64)
    reg [IN_W - 1 : 0] i_data_r;
    wire [PIX_W - 1 : 0] top;
    wire [PIX_W - 1 : 0] bot;
    wire [PIX_W - 1 : 0] left;
    wire [PIX_W - 1 : 0] right;
    localparam bias_top = 64;
    localparam bias_bot = 88 - 56;
    localparam bias_left = 72;
    localparam bias_right = 79;
    assign top = (cnt == 0) ? i_data[64 * 8 +: 8] :
        (cnt < PIX_W) ? i_data_r[(cnt + bias_top) * PIX_W +: PIX_W] : i_data_r[(cnt - PIX_W) * PIX_W +: PIX_W];
    assign bot = (cnt == 0) ? i_data[8 * 8 +: 8] :
        (cnt >= PIX_W * (PIX_W - 1)) ? i_data_r[(cnt + bias_bot) * PIX_W +: PIX_W] : i_data_r[(cnt + PIX_W) * PIX_W +: PIX_W];
    assign left = (cnt == 0) ? i_data[72 * 8 +: 8] :
       (cnt % 8 == 0) ? i_data_r[(cnt / 8 + bias_left) * PIX_W +: PIX_W] : i_data_r[(cnt - 1) * PIX_W +: PIX_W];
    assign right = (cnt == 0) ? i_data[1 * 8 +: 8] :
       ((cnt + 1) % 8 == 0) ? i_data_r[((cnt + 1) / 8 + bias_right) * PIX_W +: PIX_W] : i_data_r[(cnt + 1) * PIX_W +: PIX_W];

    assign o_data = {top, bot, left, right};
    assign request = (cnt == 0); 
    always @(posedge clk) begin
        if(~rst)
            cnt <= 0;
        else if(request && ready)
            cnt <= cnt + 1'b1;
        else if(cnt != 0)
            cnt <= cnt + 1'b1;
    end
    always @(posedge clk) begin
        if(request && ready)
            i_data_r <= i_data;
    end
    assign i_valid = (cnt != 0) ? 1 :
        (request && ready) ? 1 : 0;
    
endmodule