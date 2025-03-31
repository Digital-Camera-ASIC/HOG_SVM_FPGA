// module div: o = a / b
// a signed, b signed, o signed

module div #(
    parameter   A_W     = 8,
    parameter   B_W     = 8,
    parameter   O_I_W   = 4, // output integer width
    parameter   O_F_W   = 16, // output integer width
    localparam  O_W     = O_I_W + O_F_W // output width
) (
    input                   clk,
    input   [A_W - 1 : 0]   a,
    input   [B_W - 1 : 0]   b,
    input                   i_sign_diff,
    output  [O_W - 1 : 0]   o
);
    reg signed [A_W + O_F_W - 1 : 0] temp;
    
    reg [O_W - 1 : 0] temp2;
    wire [3 : 0] cnt_ls; // count left shift of b, for aligned
    localparam signed tan80 = 20'h5ABD9;
    localparam signed tan100 = 20'hA5426;

    wire [B_W - 1 : 0]   a_new [0 : 9];
    wire [B_W - 1 : 0]   b_new [0 : 9];
    wire sign_diff [0 : 9];
    wire [A_W + O_F_W - 1 : 0] o_new [0 : 9];
    
    div_pe_2 u_div_pe_2_0 (
        .clk      (clk),
        .a        (a),
        //quotient
        .b        (b),
        // divisor
        .o        (24'h0),
        .i_sign_diff (i_sign_diff),
        .o_sign_diff (sign_diff[0]),
        .a_new    (a_new[0]),
        // remainder
        .b_new    (b_new[0]),
        // next divisor
        // quotient
        .o_new    (o_new[0])
    );
    div_pe_2 u_div_pe_2_1 (
        .clk      (clk),
        .a        (a_new[0]),
        //quotient
        .b        (b_new[0]),
        // divisor
        .o        (o_new[0]),
        .i_sign_diff (sign_diff[0]),
        .o_sign_diff (sign_diff[1]),
        .a_new    (a_new[1]),
        // remainder
        .b_new    (b_new[1]),
        // next divisor
        // quotient
        .o_new    (o_new[1])
    );
    generate
        genvar i;
        
        for (i = 1; i < 9; i = i + 1) begin
            div_pe u_div_pe (
                .clk      (clk),
                .a        (a_new[i]),
                //quotient
                .b        (b_new[i]),
                // divisor
                .o        (o_new[i]),
                .i_sign_diff (sign_diff[i]),
                .o_sign_diff (sign_diff[i + 1]),
                .a_new    (a_new[i + 1]),
                // remainder
                .b_new    (b_new[i + 1]),
                // next divisor
                // quotient
                .o_new    (o_new[i + 1])
            );
        end
    endgenerate
    always @(posedge clk) begin
        if(b_new[9] == 0 && sign_diff[9] == 0)
            temp <= {1'b0, {(A_W + O_F_W - 1){1'b1}}};
        else if (b_new[9] == 0 && sign_diff[9] == 1)
            temp <= {1'b1, {(A_W + O_F_W - 2){1'b0}}, 1'b1};
        else if(sign_diff[9])
            temp <= ~o_new[9] + 1;
        else
            temp <= o_new[9];
        
        temp2 <= (temp > tan80) ? tan80 :
            (temp < tan100) ? tan100 : temp;
    end

    assign o = temp2;
endmodule
module div_pe(
    input                       clk,
    input   [8 - 1    : 0]    a, //quotient
    input   [8 - 1    : 0]    b, // divisor
    input   [24 - 1    : 0]    o,
    input i_sign_diff,
    output reg o_sign_diff,
    output reg [8 - 1    : 0]    a_new, // remainder
    output reg [8 - 1    : 0]    b_new, // next divisor
    output reg [24 - 1    : 0]    o_new // quotient
);
    wire [8 : 0] a_w[0 : 2];
    wire [1 : 0] o_now;
    assign a_w[0] = a << 1;
    
    assign a_w[1]= (a_w[0] >= b) ? (a_w[0] - b) << 1 : a_w[0] << 1;
    
    
    assign a_w[2] = (a_w[1] >= b) ? (a_w[1] - b) : a_w[1];
    

    assign o_now = {(a_w[0] >= b),(a_w[1] >= b)};
    always @(posedge clk) begin
        o_sign_diff <= i_sign_diff;
        b_new <= b;
        a_new <= a_w[2];
        o_new <= {o, o_now};
    end
endmodule
module div_pe_2(
    input                       clk,
    input   [8 - 1    : 0]    a, //quotient
    input   [8 - 1    : 0]    b, // divisor
    input [24 - 1    : 0]    o, // quotient
    input i_sign_diff,
    output reg o_sign_diff,
    output reg [8 - 1    : 0]    a_new, // remainder
    output reg [8 - 1    : 0]    b_new, // next divisor
    output reg [24 - 1    : 0]    o_new // quotient
);
    wire [7 : 0] a_w[0 : 2];
    wire [1 : 0] o_now;
    assign a_w[0] = (a >= b) ? (a - b) : a;
    
    assign a_w[1] = (a_w[0] >= b) ? (a_w[0] - b) : a_w[0];
    
    
    assign a_w[2] = (a_w[1] >= b) ? (a_w[1] - b) : a_w[1];

    assign o_now = (a >= b) + (a_w[1] >= b) + (a_w[0] >= b);
    always @(posedge clk) begin
        o_sign_diff <= i_sign_diff;
        b_new <= b;
        a_new <= a_w[2];
        o_new <= o_now + o;
    end
endmodule