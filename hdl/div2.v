// module div2: o = a / b
// a unsigned, b unsigned, o unsigned
`define SIM
module div2 #(
    // do not change parameters
    parameter  A_W     = 20,
    parameter  B_W     = 22,
    parameter  O_I_W   = 0, // output integer width
    parameter  O_F_W   = 32, // output integer width
    localparam  O_W     = O_I_W + O_F_W // output width
) (
    input                       clk,
    input   [A_W - 1    : 0]    a,
    input   [B_W - 1    : 0]    b,
    output  [O_W - 1    : 0]    o
);
    
    wire [B_W - 1 : 0] a_aligned;
    wire [B_W - 1 : 0] b_aligned;
    wire [4 : 0] cnt_ls; // count left shift of b, for aligned
    left_shift_msb #(
        .IN_W   (B_W),
        .CNT_W  (5)        
    ) 
    u_left_shift_msb (
        .in     (b), 
        .out    (b_aligned), 
        .cnt    (cnt_ls)
    );
    assign a_aligned = a << cnt_ls;
    // a_aligned < b_aligned
    wire [B_W - 1 : 0] a_new[0 : 15];
    wire [B_W - 1 : 0] b_new[0 : 15];
    wire [O_W - 1 : 0] o_new[0 : 15];

    div2_pe u_div2_pe0 (
        .clk      (clk),
        .a        (a_aligned),
        //quotient
        .b        (b_aligned),
        // divisor
        .o        (32'h0),
        .a_new    (a_new[0]),
        // remainder
        .b_new    (b_new[0]),
        // next divisor
        // quotient
        .o_new    (o_new[0])
    );
    generate
        genvar i;
        for (i = 0; i < 15; i = i + 1) begin
            div2_pe u_div2_pe (
                .clk      (clk),
                .a        (a_new[i]),
                //quotient
                .b        (b_new[i]),
                // divisor
                .o        (o_new[i]),
                .a_new    (a_new[i + 1]),
                // remainder
                .b_new    (b_new[i + 1]),
                // next divisor
                // quotient
                .o_new    (o_new[i + 1])
            );
        end
    endgenerate
    assign o = o_new[15];
`ifdef SIM
    reg overflow;
    always @(posedge clk) begin
        overflow <= (a_aligned >= b_aligned);
    end
`endif
endmodule
module div2_pe(
    input                       clk,
    input   [22 - 1    : 0]    a, //quotient
    input   [22 - 1    : 0]    b, // divisor
    input   [32 - 1    : 0]    o,
    output reg [22 - 1    : 0]    a_new, // remainder
    output reg [22 - 1    : 0]    b_new, // next divisor
    output reg [32 - 1    : 0]    o_new // quotient
);
    wire [22 : 0] a_w[0 : 2];
    wire [1 : 0] o_now;
    assign a_w[0] = a << 1;
    
    assign a_w[1] = (a_w[0] >= b) ? (a_w[0] - b) << 1 : a_w[0] << 1;
    assign a_w[2] = (a_w[1] >= b) ? a_w[1] - b : a_w[1];
    assign o_now = {(a_w[0] >= b),(a_w[1] >= b)};
    always @(posedge clk) begin
        b_new <= b;
        a_new <= a_w[2];
        o_new <= {o, o_now};
    end
endmodule
