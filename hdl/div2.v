// module div: o = a / b
// a unsigned, b unsigned, o unsigned

module div2 #(
    parameter   A_W     = 9,
    parameter   B_W     = 9,
    parameter   O_I_W   = 4, // output integer width
    parameter   O_F_W   = 8, // output integer width
    localparam  O_W     = O_I_W + O_F_W // output width
) (
    input                       clk,
    input   [A_W - 1    : 0]    a,
    input   [B_W - 1    : 0]    b,
    output  [O_W - 1    : 0]    o
);
    reg [O_W - 1 : 0] o_r;
    reg  [A_W + O_F_W - 1 : 0] a_w;
    always @(posedge clk) begin
        a_w <= a << O_F_W;
        o_r <= a_w / b;
    end

    assign o = o_r;
endmodule
