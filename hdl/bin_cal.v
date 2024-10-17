module bin_cal #(
    parameter TAN_W = 19,
    parameter MAG_I = 9,
    parameter MAG_F = 16
) (
    input   [TAN_W - 1 : 0]         tan,
    input                           negative,
    input   [MAG_I + MAG_F - 1 : 0] magnitude,
    output  [MAG_I + MAG_F - 1 : 0] bin0,
    output  [MAG_I + MAG_F - 1 : 0] bin20,
    output  [MAG_I + MAG_F - 1 : 0] bin40,
    output  [MAG_I + MAG_F - 1 : 0] bin60,
    output  [MAG_I + MAG_F - 1 : 0] bin80,
    output  [MAG_I + MAG_F - 1 : 0] bin100,
    output  [MAG_I + MAG_F - 1 : 0] bin120,
    output  [MAG_I + MAG_F - 1 : 0] bin140,
    output  [MAG_I + MAG_F - 1 : 0] bin160
);
    wire    [4:0] code;
    tan_decode u_tan_decode (
        .tan     (tan),
        .code    (code)
    );
    assign bin0 = (!negative && code[0]) ? magnitude : 0;
    assign bin20 = (!negative && code[1]) ? magnitude : 0;
    assign bin40 = (!negative && code[2]) ? magnitude : 0;
    assign bin60 = (!negative && code[3]) ? magnitude : 0;
    assign bin80 = (code[4]) ? magnitude : 0;
    assign bin100 = (negative && code[3]) ? magnitude : 0;
    assign bin120 = (negative && code[2]) ? magnitude : 0;
    assign bin140 = (negative && code[1]) ? magnitude : 0;
    assign bin160 = (negative && code[0]) ? magnitude : 0;
endmodule

