// svm controller
module svm_ctrl #(
    parameter   SW_W    = 11, // slide window width
    localparam  ADDR_W  = 6 // ceil of log2(36)
) (
    input                           clk,
    input                           rst,
    input                           i_valid,
    // control ram
    output reg  [ADDR_W - 1 : 0]    addr_b,  
    // control PE
    output                          init,
    output                          accumulate,
    // output info
    output      [SW_W - 1   : 0]    sw_id, // slide window index
    output                          o_valid // slide window index
);
    localparam MAX_ADDR = 36;
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
endmodule
