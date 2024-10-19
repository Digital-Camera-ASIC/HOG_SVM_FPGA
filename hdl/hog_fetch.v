module hog_fetch #(
    parameter ADDR_W = 10,
    parameter MAX_ADDR = 1199,
    parameter PIX_W = 8,
    parameter PIX_N = 96
) (
    input                               clk,
    input                               rst,
    input                               ready,
    input   [PIX_W * PIX_N - 1 : 0]     i_data,
    output                              request,
    output                              o_valid,
    output reg [ADDR_W - 1 : 0]         addr_fw
);
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



    assign is_max_addr = (addr_r == MAX_ADDR);
    
    assign addr_n = 
        ({ready, is_max_addr} == 2'b11) ? 0 :
        ({ready, is_max_addr} == 2'b10) ? addr_r + 1'b1 : addr_r;

    always @(posedge clk) begin
        if(!rst) addr_r <= 0;
        else addr_r <= addr_n;
    end

    wire [PIX_W * 8 - 1 : 0] pixel[TOP_LEFT : BOT_RIGHT];

    reg [PIX_W * 8 - 1 : 0] pixel_r[TOP_LEFT : BOT_RIGHT];
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
        i_data[(TOP_B + CELL - 3 + 1) * PIX_W - 1 : (TOP_B + CELL - 3) * PIX_W], // top
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
        i_data[(BOT_B + CELL - 3 + 1) * PIX_W - 1 : (BOT_B + CELL - 3) * PIX_W], // bottom
        i_data[(BOT_RIGHT - 1 + 1) * PIX_W - 1 : (BOT_RIGHT - 1) * PIX_W], // left
        i_data[(RIGHT_B + CELL - 3 + 1) * PIX_W - 1 : (RIGHT_B + CELL - 3 - 1) * PIX_W]  // right
    };
    //-------------
    

    // output
    assign request = 1'b1;
    integer id;
    always @(posedge clk) begin
        if(!rst) begin
            addr_fw <= 0;
            valid_r <= 0;
            for (id = TOP_LEFT; id < BOT_RIGHT; id = id + 1)
                pixel_r[id] <= 0;
        end else begin
            addr_fw <= addr_r;
            valid_r <= ready;
            for (id = TOP_LEFT; id < BOT_RIGHT; id = id + 1)
                pixel_r[id] <= pixel[id];
        end
    end
endmodule