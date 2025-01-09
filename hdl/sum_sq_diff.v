// input: top, bot, left, right
// output: (top - bot)^2 + (left - right)^2
module sum_sq_diff # (
    parameter PIX_W = 8
)(  
    input                               clk, 
    input     [PIX_W - 1  : 0]    top, 
    input     [PIX_W - 1  : 0]    bot,  
    input     [PIX_W - 1  : 0]    left,  
    input     [PIX_W - 1  : 0]    right,
    output reg signed [PIX_W : 0]       ver_diff, // the difference of vertical (bot - top)
    output reg signed [PIX_W : 0]       hor_diff, // the difference of horizon (right - left)
    output          [2 * PIX_W  : 0]    result
);
    // 
    reg [2 * PIX_W : 0]        ver_sq; // the square of ver_diff
    reg [2 * PIX_W : 0]        hor_sq; // the square of hor_diff

    reg [2 * PIX_W : 0] sum; // sum of ver_sq and hor_sq
    // reg [2 * PIX_W + 1 : 0] sum_r; // sum of ver_sq and hor_sq
    always @(posedge clk) begin
        // cycle 1
        ver_diff <= bot - top;
        hor_diff <= right - left;
        // cycle 2
        ver_sq <= ver_diff * ver_diff;
        hor_sq <= hor_diff * hor_diff;
        // cycle 3
        sum <= ver_sq + hor_sq;
    end

// Output result
    assign result = sum;
   
endmodule

