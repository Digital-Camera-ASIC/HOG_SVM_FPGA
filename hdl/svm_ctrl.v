// svm controller
module svm_ctrl #(
    parameter   SW_W    = 11, // slide window width, ceil of log2(1200)
    parameter   ADDR_W  = 6 // ceil of log2(36)
) (
    input                           clk,
    input                           rst,
    input                           i_valid,
    // control ram
    output reg  [ADDR_W - 1 : 0]    addr_b,  
    // control PE
    output reg                      init,
    output reg                      accumulate,
    // control buffer
    output reg                      valid_buf,
    // output info
    output reg  [SW_W - 1   : 0]    sw_id, // slide window index
    output                          o_valid // slide window index
);
    localparam MAX_ADDR = 36;
    localparam MAX_SW_ID = 1130;
    localparam COL_N = 39;
    localparam TH_ROW_SW = 14 * COL_N; // threshold row of slide window
    localparam TH_COL_SW = 6; // threshold columm of slide window
    always @(posedge clk) begin
        if (~rst) begin
            addr_b <= 0;
        end else if (addr_b == MAX_ADDR) begin
            addr_b <= 0;
        end else if(i_valid)
            addr_b <= addr_b + 1'b1;
    end

    
    always @(posedge clk) begin
        if (~rst) 
            init <= 0;
        else if (~|addr_b) // addr == 0
            init <= 1;
        else
            init <= 0;
    end

    always @(posedge clk) begin
        if(~rst)
            accumulate <= 0;
        else if(addr_b == MAX_ADDR)
            accumulate <= 1;
        else
            accumulate <= 0;
    end

    wire row_valid;
    wire col_valid;

    always @(posedge clk) begin
        if(~rst) begin
            sw_id <= 0;
        end else if (accumulate) begin
            if(sw_id == MAX_SW_ID - 1)
                sw_id <= 0;
            else
                sw_id <= sw_id + 1'b1;
        end
    end
    
    assign row_valid = sw_id >= TH_ROW_SW;
    assign col_valid = (sw_id % COL_N) >= TH_COL_SW;
    assign o_valid = accumulate & row_valid & col_valid;
    // control valid
    always @(posedge clk) begin
        if(~rst) begin
            valid_buf <= 0;
        end
        else if(accumulate) begin
            valid_buf <= 1;
        end else begin
            valid_buf <= 0;
        end
    end
endmodule
