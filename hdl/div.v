// module div: o = a / b
// a signed, b signed, o signed

module div #(
    parameter   A_W     = 9,
    parameter   B_W     = 9,
    parameter   O_I_W   = 4, // output integer width
    parameter   O_F_W   = 16, // output integer width
    localparam  O_W     = O_I_W + O_F_W // output width
) (
    input clk,
    input signed    [A_W - 1 : 0] a,
    input signed    [B_W - 1 : 0] b,
    output          [O_W - 1 : 0] o
);
    reg [O_W - 1 : 0] o_r;
    wire signed [A_W + O_F_W - 1 : 0] a_w;
    reg signed [A_W + O_F_W - 1 : 0] temp;
    assign a_w = a << O_F_W;
    reg [O_I_W - 1 : 0] int_part;

    always @(posedge clk) begin
        temp <= a_w / b;
        int_part <= (temp[O_F_W +: (A_W - 1)] > 7) ? 7 : temp[O_F_W +: (A_W - 1)];
        if(b == 0 && a[A_W - 1] == 0)
            o_r <= {1'b0, {(O_W - 1){1'b1}}};
        else if (b == 0 && a[A_W - 1] == 1)
            o_r <= {1'b1, {(O_W - 2){1'b0}}, 1'b1};
        else 
            o_r <= {temp[A_W + O_F_W - 1], int_part, temp[O_F_W - 1 : 0]};
    end

    assign o = o_r;
endmodule
