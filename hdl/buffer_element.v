
module buffer_element #(
    parameter DATA_W = 32
) (
    input                       clk,        // the clock
    input                       rst,        // reset signal
    input   [DATA_W - 1 : 0]    i_data,     // input data
    input                       i_valid,    // input valid signal
    output  [DATA_W - 1 : 0]    o_data     // output data
);
    reg     [DATA_W - 1 : 0]    b_data;     // the data buffer
    
    // output
    assign o_data = b_data;

    always @(posedge clk) begin
        if(!rst)
            b_data <= {DATA_W{1'b0}};
        else if (i_valid)
            b_data <= i_data;
        else
            b_data <= b_data;
    end

    
endmodule
