// serial_to_parallel module: 
// to convert 2 serial input data to 1 output data with double data width
module serial_to_parallel #(
    parameter DATA_W = 32
) (
    input                               clk,
    input                               rst,
    input   [DATA_W - 1 : 0]            i_data,
    input                               i_valid,
    input                               clear,
    output  [DATA_W * 2 - 1 : 0]        o_data,
    output                          o_valid
);
    wire    [DATA_W - 1 : 0]            _data [0 : 2];

    wire o_valid_ctr;
    reg o_valid_r;
    always @(posedge clk) begin
        if (!rst) begin
            o_valid_r <= 0;
        end else begin
            o_valid_r <= o_valid_ctr;
        end
    end
    assign o_valid = o_valid_r | o_valid_ctr;
    assign _data[0] = i_data;
    assign o_data = {_data[2], _data[1]};

    buffer_ctr #(
        .DEPTH      (2)
    ) u_buffer_ctr (
        .clk        (clk),
        // the clock
        .rst        (rst),
        // reset signal
        .clear      (clear),
        .i_valid    (i_valid),
        // input valid signal
        .o_valid    (o_valid_ctr)
    );

    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin
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