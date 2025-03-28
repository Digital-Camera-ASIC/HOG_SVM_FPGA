module buffer #(
    parameter DATA_W    = 32,
    parameter DEPTH     = 2
) (
    input                       clk,        // the clock
    input                       rst,        // reset signal
    input   [DATA_W - 1 : 0]    i_data,     // input data
    input                       clear,      // clear counter
    input                       i_valid,    // input valid signal
    output  [DATA_W - 1 : 0]    o_data,      // output data
    output                      o_valid     // output valid
);
    wire [DATA_W - 1 : 0]       _data [0 : DEPTH];

    assign _data[0] = i_data;
    assign o_data = _data[DEPTH];

    buffer_ctr #(
        .DEPTH      (DEPTH)
    ) u_buffer_ctr (
        .clk        (clk),
        // the clock
        .rst        (rst),
        // reset signal
        .clear      (clear),
        .i_valid    (i_valid),
        // input valid signal
        .o_valid    (o_valid)
    );
    genvar i;
    generate
        for (i = 0; i < DEPTH; i = i + 1) begin : BUFFER_ELEMENT_GEN
            buffer_element #(
                .DATA_W     (DATA_W)
            ) u_buffer_element (
                .clk        (clk),
                // the clock
                .rst        (rst),
                // reset signal
                .i_data     (_data[i]),
                // input data
                .i_valid    (i_valid),
                // input valid signal
                // output data
                .o_data     (_data[i + 1])
            );
        end
    endgenerate
endmodule
