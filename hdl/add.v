// add 32-bit fixed point module following the specification
// input could be positive or negative numbers
// res = a + b

module add (
    output [31 : 0] res,
    input [31 : 0] a,
    input [31 : 0] b
);
    wire [32 : 0] sum;
    assign sum = a + b;
    assign res =    (a == 0 || a == 32'h80000000) ? b : 
                    (b == 0 || b == 32'h80000000) ? a : sum[31:0];

endmodule