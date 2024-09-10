// subtract 32-bit fixed point module following the specification
// input could be positive or negative numbers
// res = a - b = a + (-b)

module sub (
    output [31 : 0] res,
    input [31 : 0] a,
    input [31 : 0] b
);
    wire [31 : 0] b_inv;

    assign b_inv = ~b + 1'b1;

    add u_add (
    .res          (res),
    .a            (a),
    .b            (b_inv)
);
    
endmodule