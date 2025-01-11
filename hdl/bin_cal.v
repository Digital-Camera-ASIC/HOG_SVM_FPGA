module bin_cal #(
    parameter   TAN_W   = 12,
    parameter   MAG_I   = 9,
    parameter   MAG_F   = 4,
    parameter   BIN_I   = 16, // integer part of bin
    localparam  BIN_F   = MAG_F, // fractional part of bin
    localparam  BIN_W   = BIN_I + BIN_F, // fractional part of bin
    localparam  MAG_W   = MAG_I + MAG_F
) (
    input                           clk,
    input                           rst,
    input                           i_valid,
    input   [MAG_W - 1      : 0]    magnitude,
    input   [TAN_W - 1      : 0]    tan,
    output                          o_valid,
    output  [BIN_W * 9 - 1  : 0]    bin

);
    reg [BIN_W - 1 : 0] bin_r [0 : 8]; // bin[0] for 0-20, 1 for 20-40,...
    wire [2 : 0] code;
    wire [5 : 0] cnt;

    bin_ctr u_bin_ctr (
        .clk        (clk),
        .rst        (rst),
        .i_valid    (i_valid),
        .tan        (tan),
        .code       (code),
        .cnt        (cnt),
        .o_valid    (o_valid)
    );
    integer i;
    always @(posedge clk) begin
        if(i_valid) begin
            if(!cnt) begin
                for(i = 0; i < 9; i = i + 1)
                    bin_r[i] <= 0;
                bin_r[code] <= magnitude;
            end else begin
                bin_r[code] <= bin_r[code] + magnitude;
            end       
        end
    end
    assign bin = {
        bin_r[8],
        bin_r[7],
        bin_r[6],
        bin_r[5],
        bin_r[4],
        bin_r[3],
        bin_r[2],
        bin_r[1],
        bin_r[0]
    };
endmodule
