module hog_fetch #(
    parameter ADDR_W = 10,
    parameter PIX_W = 8, // pixel width
    parameter PIX_N = 96,
    parameter MAG_I = 9, // integer part of magnitude
    parameter MAG_F = 16,// fraction part of magnitude
    parameter TAN_W = 19, // tan width
    parameter BIN_I =   16, // integer part of bin
    parameter BIN_F =   16 // fractional part of bin
    
) (
    input                                       clk,
    input                                       rst,
    input                                       ready,
    input   [PIX_W * PIX_N - 1 : 0]             i_data,
    output                                      request,
    output reg                                  o_valid,
    output reg [ADDR_W - 1 : 0]                 addr_fw,
    output reg [ADDR_W - 1 : 0]                 address,
    output reg [9 * (BIN_I + BIN_F) - 1 : 0]    bin
);

    localparam MAX_ADDR = 1199;
    // the size of cell
    localparam CELL = 8;
    
    // start end of center
    localparam CEN_S = 9;
    localparam CEN_E = 54;

    // start, end and bias of top edge
    localparam TOP_S = 1;
    localparam TOP_E = 6;
    localparam TOP_B = 65;

    // start, end and bias of bottom edge
    localparam BOT_S = 57;
    localparam BOT_E = 62;
    localparam BOT_B = 89;

    // start, end and bias of left edge
    localparam LEFT_S = 8;
    localparam LEFT_E = 48;
    localparam LEFT_B = 73;

    // start, end and bias of right edge
    localparam RIGHT_S = 15;
    localparam RIGHT_E = 55;
    localparam RIGHT_B = 81;

    // corner pixel
    localparam TOP_LEFT = 0;
    localparam TOP_RIGHT = 7;
    localparam BOT_LEFT = 56;
    localparam BOT_RIGHT = 63;
    reg [ADDR_W - 1 : 0] addr_r;

    wire [ADDR_W - 1 : 0] addr_n;

    reg valid_r;
    reg valid_r1;
    reg [ADDR_W - 1 : 0] address_r;
    assign is_max_addr = (addr_r == MAX_ADDR);
    
    assign addr_n = 
        ({ready, is_max_addr} == 2'b11) ? 0 :
        ({ready, is_max_addr} == 2'b10) ? addr_r + 1'b1 : addr_r;

    always @(posedge clk) begin
        if(!rst) addr_r <= 0;
        else addr_r <= addr_n;
    end

    wire [PIX_W * 4 - 1 : 0] pixel[TOP_LEFT : BOT_RIGHT];

    reg [PIX_W * 4 - 1 : 0] pixel_r[TOP_LEFT : BOT_RIGHT];

    // split data into pixel
    genvar i;
    generate
        // center
        for(i = CEN_S; i <= CEN_E; i = ((i + 2) % CELL == 0) ? i + 3 : i + 1) begin
            assign pixel[i] = {
                i_data[(i - CELL + 1) * PIX_W - 1 : (i - CELL) * PIX_W], // top
                i_data[(i + CELL + 1) * PIX_W - 1 : (i + CELL) * PIX_W], // bottom
                i_data[(i - 1 + 1) * PIX_W - 1 : (i - 1) * PIX_W], // left
                i_data[(i + 1 + 1) * PIX_W - 1 : (i + 1) * PIX_W]  // right
            };
        end
        // top edge
        for(i = TOP_S; i <= TOP_E; i = i + 1)begin
            assign pixel[i] = {
                i_data[(TOP_B + i - TOP_S + 1) * PIX_W - 1 : (TOP_B + i - TOP_S) * PIX_W], // top
                i_data[(i + CELL + 1) * PIX_W - 1 : (i + CELL) * PIX_W], // bottom
                i_data[(i - 1 + 1) * PIX_W - 1 : (i - 1) * PIX_W], // left
                i_data[(i + 1 + 1) * PIX_W - 1 : (i + 1) * PIX_W]  // right
            };
        end
        // bottom edge
        for(i = BOT_S; i <= BOT_E; i = i + 1) begin
            assign pixel[i] = {
                i_data[(i - CELL + 1) * PIX_W - 1 : (i - CELL) * PIX_W], // top
                i_data[(BOT_B + i - BOT_S + 1) * PIX_W - 1 : (BOT_B + i - BOT_S) * PIX_W], // bottom
                i_data[(i - 1 + 1) * PIX_W - 1 : (i - 1) * PIX_W], // left
                i_data[(i + 1 + 1) * PIX_W - 1 : (i + 1) * PIX_W]  // right
            };
        end
        // right edge
        for(i = RIGHT_S; i <= RIGHT_E; i = i + CELL) begin
            assign pixel[i] = {
                i_data[(i - CELL + 1) * PIX_W - 1 : (i - CELL) * PIX_W], // top
                i_data[(i + CELL + 1) * PIX_W - 1 : (i + CELL) * PIX_W], // bottom
                i_data[(i - 1 + 1) * PIX_W - 1 : (i - 1) * PIX_W], // left
                i_data[(RIGHT_B + (i - RIGHT_S)/CELL + 1) * PIX_W - 1 : (RIGHT_B + (i - RIGHT_S)/CELL) * PIX_W]  // right
            };
        end
        // left edge
        for(i = LEFT_S; i <= LEFT_E; i = i + CELL) begin
            assign pixel[i] = {
                i_data[(i - CELL + 1) * PIX_W - 1 : (i - CELL) * PIX_W], // top
                i_data[(i + CELL + 1) * PIX_W - 1 : (i + CELL) * PIX_W], // bottom
                i_data[(LEFT_B + (i - LEFT_S)/CELL + 1) * PIX_W - 1 : (LEFT_B + (i - LEFT_S)/CELL) * PIX_W], // left
                i_data[(i + 1 + 1) * PIX_W - 1 : (i + 1) * PIX_W]  // right
            };
        end
    endgenerate
    // corner
    assign pixel[TOP_LEFT] = {
        i_data[(TOP_B - 1 + 1) * PIX_W - 1 : (TOP_B - 1) * PIX_W], // top
        i_data[(TOP_LEFT + CELL + 1) * PIX_W - 1 : (TOP_LEFT + CELL) * PIX_W], // bottom
        i_data[(LEFT_B - 1 + 1) * PIX_W - 1 : (LEFT_B - 1) * PIX_W], // left
        i_data[(TOP_LEFT + 1 + 1) * PIX_W - 1 : (TOP_LEFT + 1) * PIX_W]  // right
    };
    assign pixel[TOP_RIGHT] = {
        i_data[(TOP_B + CELL - 2 + 1) * PIX_W - 1 : (TOP_B + CELL - 2) * PIX_W], // top
        i_data[(TOP_RIGHT + CELL + 1) * PIX_W - 1 : (TOP_RIGHT + CELL) * PIX_W], // bottom
        i_data[(TOP_RIGHT - 1 + 1) * PIX_W - 1 : (TOP_RIGHT - 1) * PIX_W], // left
        i_data[(RIGHT_B - 1 + 1) * PIX_W - 1 : (RIGHT_B - 1) * PIX_W]  // right
    };
    assign pixel[BOT_LEFT] = {
        i_data[(BOT_LEFT - CELL + 1) * PIX_W - 1 : (BOT_LEFT - CELL) * PIX_W], // top
        i_data[(BOT_B - 1 + 1) * PIX_W - 1 : (BOT_B - 1) * PIX_W], // bottom
        i_data[(LEFT_B - 1 + 1) * PIX_W - 1 : (LEFT_B - 1) * PIX_W], // left
        i_data[(BOT_LEFT + 1 + 1) * PIX_W - 1 : (BOT_LEFT + 1) * PIX_W]  // right
    };

    assign pixel[BOT_RIGHT] = {
        i_data[(BOT_RIGHT - CELL + 1) * PIX_W - 1 : (BOT_RIGHT - CELL) * PIX_W], // top
        i_data[(BOT_B + CELL - 2 + 1) * PIX_W - 1 : (BOT_B + CELL - 2) * PIX_W], // bottom
        i_data[(BOT_RIGHT - 1 + 1) * PIX_W - 1 : (BOT_RIGHT - 1) * PIX_W], // left
        i_data[(RIGHT_B + CELL - 2 + 1) * PIX_W - 1 : (RIGHT_B + CELL - 2) * PIX_W]  // right
    };
    //-------------
    

    // output
    assign request = 1'b1;
    integer id;
    always @(posedge clk) begin
        if(!rst) begin
            addr_fw <= 0;
            valid_r <= 0;
            for (id = TOP_LEFT; id <= BOT_RIGHT; id = id + 1)
                pixel_r[id] <= 0;
        end else begin
            addr_fw <= addr_r;
            valid_r <= ready;
            for (id = TOP_LEFT; id <= BOT_RIGHT; id = id + 1)
                pixel_r[id] <= pixel[id];
        end
    end

    wire [MAG_I + MAG_F - 1 : 0] bin0[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin20[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin40[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin60[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin80[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin100[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin120[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin140[TOP_LEFT : BOT_RIGHT];
    wire [MAG_I + MAG_F - 1 : 0] bin160[TOP_LEFT : BOT_RIGHT];
    generate;
        for (i = TOP_LEFT; i <= BOT_RIGHT; i = i + 1) begin
            mag_cal_sbs #(
                .PIX_W     (PIX_W),
                // pixel width
                .MAG_I     (MAG_I),
                // integer part of magnitude
                .MAG_F     (MAG_F),
                // fraction part of magnitude
                // tan width
                .TAN_W     (TAN_W)
            ) u_mag_cal_sbs (
                .clk       (clk),
                .rst       (rst),
                .pixel     (pixel_r[i]),
                .bin0      (bin0[i]),
                .bin20     (bin20[i]),
                .bin40     (bin40[i]),
                .bin60     (bin60[i]),
                .bin80     (bin80[i]),
                .bin100    (bin100[i]),
                .bin120    (bin120[i]),
                .bin140    (bin140[i]),
                .bin160    (bin160[i])
            );
        end
    endgenerate

    reg [BIN_I + BIN_F - 1 : 0] bin0_s; // sum of 63 bin0
    reg [BIN_I + BIN_F - 1 : 0] bin20_s; // sum of 63 bin20
    reg [BIN_I + BIN_F - 1 : 0] bin40_s; // sum of 63 bin40
    reg [BIN_I + BIN_F - 1 : 0] bin60_s; // sum of 63 bin60
    reg [BIN_I + BIN_F - 1 : 0] bin80_s; // sum of 63 bin80
    reg [BIN_I + BIN_F - 1 : 0] bin100_s; // sum of 63 bin100
    reg [BIN_I + BIN_F - 1 : 0] bin120_s; // sum of 63 bin120
    reg [BIN_I + BIN_F - 1 : 0] bin140_s; // sum of 63 bin140
    reg [BIN_I + BIN_F - 1 : 0] bin160_s; // sum of 63 bin160

    always @(*) begin
        for(id = TOP_LEFT; id <= BOT_RIGHT; id = id + 1)begin
            if(id == TOP_LEFT) begin
                bin0_s = bin0[TOP_LEFT];
                bin20_s = bin20[TOP_LEFT];
                bin40_s = bin40[TOP_LEFT];
                bin60_s = bin60[TOP_LEFT];
                bin80_s = bin80[TOP_LEFT];
                bin100_s = bin100[TOP_LEFT];
                bin120_s = bin120[TOP_LEFT];
                bin140_s = bin140[TOP_LEFT];
                bin160_s = bin160[TOP_LEFT];
            end else begin
                bin0_s = bin0_s + bin0[id];
                bin20_s = bin20_s + bin20[id];
                bin40_s = bin40_s + bin40[id];
                bin60_s = bin60_s + bin60[id];
                bin80_s = bin80_s + bin80[id];
                bin100_s = bin100_s + bin100[id];
                bin120_s = bin120_s + bin120[id];
                bin140_s = bin140_s + bin140[id];
                bin160_s = bin160_s + bin160[id];
            end
        end
    end
    // sub-system
    always @(posedge clk) begin
        if(!rst) begin
            bin <= 0;
            valid_r1 <= 0;
            o_valid <= 0;
            address_r <= 0;
            address <= 0;
        end
        else begin
            bin <= {bin160_s, bin140_s, bin120_s, bin100_s, bin80_s, bin60_s, bin40_s, bin20_s, bin0_s};
            valid_r1 <= valid_r;
            o_valid <= valid_r1;
            address_r <= addr_fw;
            address <= address_r;
        end
    end
endmodule