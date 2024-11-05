// svm controller
module svm_ctrl #(
    parameter SW_W = 11 // slide window width
) (
    input                   clk,
    input                   rst,
    input                   i_valid,
    output                  o_valid,
    output [SW_W - 1 : 0]   sw_id // slide window index
);
    localparam MAX_SW = 1130;
    localparam COL_N = 39;
    localparam TH_ROW_SW = 14 * COL_N; // threshold row of slide window
    localparam TH_COL_SW = 6; // threshold columm of slide window

    reg [SW_W - 1 : 0] cnt;
    wire [SW_W - 1 : 0] cnt_n;
    
    wire row_valid;
    wire col_valid;

    always @(posedge clk) begin
        if(!rst) cnt <= 0;
        else cnt <= cnt_n;
    end
    
    assign cnt_n = 
        (!i_valid) ? cnt :
        (cnt == MAX_SW) ? 0 : cnt + 1'b1;
    

    assign row_valid = cnt >= TH_ROW_SW;
    assign col_valid = (cnt % COL_N) >= TH_COL_SW;
    assign o_valid = row_valid & col_valid & i_valid;
    assign sw_id = cnt;
endmodule