// multiply 32-bit fixed point module following the specification
// input could be positive or negative numbers
// res = a * b

module mul (
    output [31 : 0] res,
    input [31 : 0] a,
    input [31 : 0] b
);
    wire [63:0] product;

    assign product = a * b;
    
endmodule