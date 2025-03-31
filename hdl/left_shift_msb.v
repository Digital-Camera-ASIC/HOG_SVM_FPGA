module left_shift_msb #(
    parameter IN_W = 22,
    parameter CNT_W = 5
)(
    input  [IN_W - 1 : 0] in,
    output reg [IN_W - 1 : 0] out,
    output reg [CNT_W - 1 : 0] cnt
);
    integer i;
    always @(*) begin
        out = in;
        cnt = 0;
        for (i = 0; i < IN_W && out[IN_W - 1] == 0; i = i + 1) begin
            out = out << 1;
            cnt = i + 1;
        end
    end
endmodule