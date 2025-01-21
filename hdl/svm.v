// svm human detection
module svm #(
    parameter   FEA_I   = 4, // integer part of hog feature
    parameter   FEA_F   = 8, // fractional part of hog feature
    parameter   SW_W    = 11, // slide window width
    localparam  FEA_W   = FEA_I + FEA_F,
    localparam  COEF_W  = FEA_W,
    localparam  N_COEF  = 105, // number of coef in a fetch instruction
    localparam  RAM_DW  = COEF_W * N_COEF,
    localparam  ADDR_W  = 6 // ceil of log2(36)
) (
    input                       clk,
    input                       rst,
    // ram interface
    input   [ADDR_W - 1 : 0]    addr_a,
    input                       write_en,
    input   [RAM_DW - 1 : 0]    i_data,
    output  [RAM_DW - 1 : 0]    o_data_a,
    // hog interface
    input                       i_valid,
    input   [FEA_W - 1  : 0]    fea,
    // output info
    output                      o_valid,
    output                      is_person,
    output  [FEA_W - 1  : 0]    result,
    output  [SW_W - 1   : 0]    sw_id // slide window index
);
    wire [RAM_DW - 1 : 0] o_data_b;
    wire [COEF_W - 1 : 0] coef [0 : N_COEF - 1];
    
    dp_ram2 #(
        .DATA_W      (RAM_DW),
        .ADDR_W      (ADDR_W)
    ) u_dp_ram2 (
        .clk         (clk),
        .addr_a      (addr_a),
        .write_en    (write_en),
        .i_data      (i_data),
        .o_data_a    (o_data_a),
        .addr_b      (addr_b),
        .o_data_b    (o_data_b)
    );
    generate
        genvar i;
        for(i = 0; i < N_COEF; i = i + 1) begin
            assign coef[i] = o_data_b[COEF_W * i +: COEF_W];
        end
    endgenerate
endmodule
