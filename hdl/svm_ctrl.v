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
    output reg                      o_valid // slide window index
);
    localparam MAX_ADDR = 36;
    localparam MAX_SW_ID = 1130;
    localparam ACC_NUM = 2;
    localparam COL_N = 39;
    localparam TH_ROW_SW = 14 * COL_N; // threshold row of slide window
    localparam TH_COL_SW = 6; // threshold columm of slide window
    reg acc_r [0 : ACC_NUM - 1];
    always @(posedge clk) begin
        if (~rst) begin
            addr_b <= 0;
        end else if (i_valid) begin
            if(addr_b == MAX_ADDR)
                addr_b <= 0;
            else
                addr_b <= addr_b + 1'b1;
        end
    end

    always @(posedge clk) begin
        if (~rst) 
            init <= 0;
        else if (~|addr_b) // addr == 0
            init <= 1;
        else
            init <= 0;
    end

    generate
        always @(posedge clk) begin
            if(~rst)
                acc_r[0] <= 0;
            else if(addr_b == MAX_ADDR)
                acc_r[0] <= 1;
            else
                acc_r[0] <= 0;
        end
        genvar i;
        for(i = 1; i < ACC_NUM; i = i + 1) begin
            always @(posedge clk) begin
                if(~rst)
                    acc_r[i] <= 0;
                else 
                    acc_r[i] <= acc_r[i - 1];
            end
        end

        always @(posedge clk) begin
            if(~rst)
                accumulate <= 0;
            else
                accumulate <= acc_r[ACC_NUM - 1];
        end
    endgenerate

    wire row_valid;
    wire col_valid;

    always @(posedge clk) begin
        if(~rst) begin
            sw_id <= 0;
        end else if (accumulate) begin
            if(sw_id == MAX_SW_ID)
                sw_id <= 0;
            else
                sw_id <= sw_id + 1'b1;
        end
    end
    
    assign row_valid = sw_id >= TH_ROW_SW;
    assign col_valid = (sw_id % COL_N) >= TH_COL_SW;
    // control valid
    always @(posedge clk) begin
        if(~rst) begin
            valid_buf <= 0;
            o_valid <= 0;
        end
        else if(accumulate) begin
            valid_buf <= 1;
            o_valid <= row_valid & col_valid;
        end else begin
            valid_buf <= 0;
            o_valid <= 0;
        end
    end
endmodule
