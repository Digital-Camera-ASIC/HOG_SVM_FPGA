module tan_decode(
    input [19 - 1 : 0] tan,
    output [5 - 1 : 0] code
);
localparam tan20 = 19'h5d2d;
localparam tan40 = 19'hd6cf;
localparam tan60 = 19'h1bb68;
localparam tan80 = 19'h5abd9;
// (tan < tan20) → code_0
// (tan20 ≤ tan < tan40) → code_1
// (tan40 ≤ tan < tan60) → code_2
// (tan60 ≤ tan < tan80) → code_3
// (tan80 ≤ tan) → code_4
    assign code[0] = tan < tan20;
    assign code[1] = tan20 <= tan && tan < tan40;
    assign code[2] = tan40 <= tan && tan < tan60;
    assign code[3] = tan60 <= tan && tan < tan80;
    assign code[4] = tan80 <= tan;
endmodule