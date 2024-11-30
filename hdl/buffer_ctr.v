module buffer_ctr #(
    parameter DEPTH = 78
) (
    input           clk,        // the clock
    input           rst,        // reset signal
    input           clear,
    input           i_valid,    // input valid signal
    output          o_valid 
);
    reg     [31:0]  cnt;
    wire    [31:0]  n_cnt;
    wire            full;

    assign o_valid = full & i_valid;

    assign full = (cnt == DEPTH);

    assign n_cnt =
        (clear) ? 32'b0 :
        (i_valid && !full) ? cnt + 1'b1 : cnt;
    
    always @(posedge clk) begin
        if(!rst)
            cnt = 32'b0;
        else
            cnt = n_cnt;
    end
endmodule
