// module div: o = a / b
// a signed, b signed, o signed

module div #(
    parameter   A_W     = 9,
    parameter   B_W     = 9,
    parameter   O_I_W   = 4, // output integer width
    parameter   O_F_W   = 16, // output integer width
    parameter  O_W     = O_I_W + O_F_W // output width
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
    reg [O_W - 1 : 0] temp2;

    localparam signed tan80 = 20'h5ABD9;
    localparam signed tan100 = 20'hA5426;
    always @(posedge clk) begin
        if(b == 0 && a[A_W - 1] == 0)
            temp <= {1'b0, {(O_W - 1){1'b1}}};
        else if (b == 0 && a[A_W - 1] == 1)
            temp <= {1'b1, {(O_W - 2){1'b0}}, 1'b1};
        else 
            temp <= a_w / b;
        
        temp2 <= (temp > tan80) ? tan80 :
            (temp < tan100) ? tan100 : temp;
        o_r <= temp2;
        
    end

    assign o = o_r;
endmodule
