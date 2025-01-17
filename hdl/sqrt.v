// pipeline sqrt
// cycle for pipeline = width of output
module sqrt #(
    parameter           IN_W    = 18,
    parameter           OUT_F   = 4,
    localparam integer  OUT_I   = $ceil(IN_W * 1.0 / 2),
    localparam          OUT_W   = OUT_I + OUT_F
) (
    input                       clk,
    input  [IN_W - 1    : 0]    in,
    output [OUT_W - 1   : 0]    out
);
    localparam IN_ALI_W = 2 * OUT_W;
    // checker for parameters
    generate    
        if(IN_W > IN_ALI_W)
            initial $error("in sqrt: IN_W > IN_ALI_W (%d, %d)", IN_W, IN_ALI_W);
    endgenerate

    
    wire [IN_ALI_W - 1 : 0] in_ali; // aligned input, depend on output width 

    assign in_ali = in << (IN_ALI_W - OUT_I * 2);

    wire [IN_ALI_W - 1 : 0] d_o [0 : OUT_W - 1];
    wire [OUT_W - 1 : 0] q_o [0 : OUT_W - 1];
    genvar i;

    generate
        sqrt_pe #(
            .Q_W     (OUT_W),
            //quotient width
            .LOOP    (1)
            //the loop to calculate cut
        ) u_sqrt_pe_0 (
            .clk     (clk),
            .d_i     (in_ali),
            // input of divident
            .q_i     ({OUT_W{1'b0}}),
            // input of quotient (divisor)
            .d_o     (d_o[0]),
            // output of new divident (remainder)
            .q_o     (q_o[0])
            // output of new quotient
        );
        for(i = 2 ; i <= OUT_W; i = i + 1) begin
            if(2 * i < OUT_W + 2) begin
                sqrt_pe #(
                    .Q_W     (OUT_W),
                    //quotient width
                    .LOOP    (i)
                    //the loop to calculate cut
                ) u_sqrt_pe (
                    .clk     (clk),
                    .d_i     (d_o[i - 2]),
                    // input of divident
                    .q_i     (q_o[i - 2]),
                    // input of quotient (divisor)
                    .d_o     (d_o[i - 1]),
                    // output of new divident (remainder)
                    .q_o     (q_o[i - 1])
                    // output of new quotient
                );
            end else begin
                sqrt_pe2 #(
                    .Q_W     (OUT_W),
                    //quotient width
                    .LOOP    (i)
                    //the loop to calculate cut
                ) u_sqrt_pe2 (
                    .clk     (clk),
                    .d_i     (d_o[i - 2]),
                    // input of divident
                    .q_i     (q_o[i - 2]),
                    // input of quotient (divisor)
                    .d_o     (d_o[i - 1]),
                    // output of new divident (remainder)
                    .q_o     (q_o[i - 1])
                    // output of new quotient
                );
            end
        end
    endgenerate
    assign out = q_o[OUT_W - 1];
endmodule

module sqrt_pe2 #(
    parameter Q_W   = 12, //quotient width
    parameter LOOP  = 1, //the loop to calculate cut
    localparam D_W  = 2 * Q_W //divident width
) (
    input                       clk,
    input       [D_W - 1 :  0]  d_i, // input of divident
    input       [Q_W - 1 :  0]  q_i, // input of quotient (divisor)
    output reg  [D_W - 1 :  0]  d_o, // output of new divident (remainder)
    output reg  [Q_W - 1 :  0]  q_o // output of new quotient
);
    generate
        if (LOOP == 0)
            initial $error("in sqrt pe: LOOP = 0");
        if(D_W < LOOP * 2)
            initial $error("in sqrt pe: D_W < LOOP * 2 (%d, %d)", D_W, LOOP * 2);
        if(LOOP * 2 < Q_W + 2)
            initial $error("in sqrt pe: LOOP * 2 < Q_W + 2 (%d, %d)", LOOP * 2, Q_W + 2);
    endgenerate
    
    localparam CUT = D_W - LOOP * 2;
    wire signed [LOOP * 2 - 1 : 0] ac_d; // actual divident
    wire signed [Q_W + 1 : 0] ac_dr; // actual divisor
    wire sign;


    wire signed [LOOP * 2 : 0] ac_r; // actual remainder
    assign sign = ac_r[LOOP * 2];

    assign ac_dr = {q_i, 2'b01};
    assign ac_d = d_i[D_W - 1 : CUT];
    assign ac_r = ac_d - ac_dr;

    generate
        if(CUT > 0) begin
            always @(posedge clk) begin
                if (sign) begin
                    // if remainder < 0 
                    d_o <= d_i;
                    q_o <= q_i << 1;
                end else begin
                    // if remainder >= 0 
                    d_o <= {ac_r, d_i[CUT - 1 : 0]};
                    q_o <= {q_i, 1'b1};
                end
            end
        end else begin
            always @(posedge clk) begin
                if (sign) begin
                    // if remainder < 0 
                    d_o <= d_i;
                    q_o <= q_i << 1;
                end else begin
                    // if remainder >= 0 
                    d_o <= ac_r;
                    q_o <= {q_i, 1'b1};
                end
            end
        end
    endgenerate

endmodule

module sqrt_pe #(
    parameter Q_W   = 12, //quotient width
    parameter LOOP  = 1, //the loop to calculate cut
    localparam D_W  = 2 * Q_W //divident width
) (
    input                       clk,
    input       [D_W - 1 :  0]  d_i, // input of divident
    input       [Q_W - 1 :  0]  q_i, // input of quotient (divisor)
    output reg  [D_W - 1 :  0]  d_o, // output of new divident (remainder)
    output reg  [Q_W - 1 :  0]  q_o // output of new quotient
);
    generate
        if (LOOP == 0)
            initial $error("in sqrt pe: LOOP = 0");
        if(D_W < LOOP * 2)
            initial $error("in sqrt pe: D_W < LOOP * 2 (%d, %d)", D_W, LOOP * 2);
        if(LOOP * 2 >= Q_W + 2)
            initial $error("in sqrt pe: LOOP * 2 >= Q_W + 2 (%d, %d)", LOOP * 2, Q_W + 2);
    endgenerate
    
    localparam CUT = D_W - LOOP * 2;
    wire [LOOP * 2 - 1 : 0] ac_d; // actual divident
    wire signed [Q_W + 1 : 0] ac_dr; // actual divisor
    wire sign;

    wire signed [Q_W + 2 : 0] ac_r; // actual remainder
    

    assign ac_dr = {q_i, 2'b01};

    assign ac_d = d_i[D_W - 1 : CUT];
    assign ac_r = ac_d - ac_dr;

    assign sign = ac_r[Q_W + 2];
    generate
        if(CUT > 0) begin
            always @(posedge clk) begin
                if (sign) begin
                    // if remainder < 0 
                    d_o <= d_i;
                    q_o <= q_i << 1;
                end else begin
                    // if remainder >= 0 
                    d_o <= {ac_r, d_i[CUT - 1 : 0]};
                    q_o <= {q_i, 1'b1};
                end
            end
        end else begin
            always @(posedge clk) begin
                if (sign) begin
                    // if remainder < 0 
                    d_o <= d_i;
                    q_o <= q_i << 1;
                end else begin
                    // if remainder >= 0 
                    d_o <= ac_r;
                    q_o <= {q_i, 1'b1};
                end
            end
        end
    endgenerate

endmodule