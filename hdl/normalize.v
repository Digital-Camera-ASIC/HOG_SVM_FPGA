module normalize #(
    parameter BIN_I     = 16, // integer part of bin
    parameter BIN_F     = 4, // fractional part of bin
    parameter FEA_I     = 4, // integer part of hog feature
    parameter FEA_F     = 8, // fractional part of hog feature
    localparam BIN_W    = BIN_I + BIN_F, // fractional part of hog feature
    localparam FEA_W    = FEA_I + FEA_F // fractional part of hog feature
) (
    input                           clk,
    input                           rst,
    input   [9 * BIN_W - 1  : 0]    bin,
    input                           i_valid,
    output  [FEA_W - 1      : 0]    fea,
    output                          o_valid
);
    localparam SUM_W = BIN_W + 2;
    localparam ADDR_W = 6;
    localparam MAX_ADDR = 42;
    localparam CELL_NUM = 1200;
    localparam CNT_W = 11; // ceil log2(CELL_NUM)
    localparam QUO_I = 0;
    localparam QUO_F = FEA_F * 2;
    localparam QUO_W = QUO_I + QUO_F;
    localparam LINE = 40;
    localparam epsilon = 12'h1;
    // shared mem for rd and wr
    reg [CNT_W - 1 : 0] cnt;
    reg o_valid_r;
    always @(posedge clk) begin
        if(!rst)
            cnt <= 0;
        else if(i_valid) begin
            if(cnt == CELL_NUM)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end else if(cnt == CELL_NUM && o_valid_r && ~o_valid) begin
                cnt <= 0;
        end
    end
    
    // controller for write into ram (every 80 cycles)
    wire [ADDR_W - 1 : 0] addr_a;
    
    assign addr_a = cnt % MAX_ADDR;

    // controller for read ram
    reg [6 : 0] cnt_after_valid;
    reg [ADDR_W - 1 : 0] addr_b;
    wire [9 * BIN_W - 1 : 0] o_data;
    always @(posedge clk) begin
        if(!rst)
            cnt_after_valid <= 0;
        else if(i_valid)
            cnt_after_valid <= 1;
        else
            cnt_after_valid <= cnt_after_valid + 1;
    end

    localparam div_with_fea_a = 8;
    localparam div_with_fea_b = div_with_fea_a + 9;
    localparam div_with_fea_c = div_with_fea_b + 9;
    localparam div_with_fea_d = div_with_fea_c + 9;
    always @(*) begin
        // control addr b
        if(cnt_after_valid == 1 || (div_with_fea_a <= cnt_after_valid && cnt_after_valid < div_with_fea_b)) begin
            addr_b = addr_a;
        end else if(cnt_after_valid == 2 || (div_with_fea_b <= cnt_after_valid && cnt_after_valid < div_with_fea_c)) begin
            if(addr_a == MAX_ADDR - 1)
                addr_b = 0;
            else
                addr_b = addr_a + 1;
        end else if(cnt_after_valid == 3 || (div_with_fea_c <= cnt_after_valid && cnt_after_valid < div_with_fea_d)) begin
            if (addr_a == 0)
                addr_b = MAX_ADDR - 2;
            else if (addr_a == 1)
                addr_b = MAX_ADDR - 1;
            else
                addr_b = addr_a - 2;
        end else if(cnt_after_valid == 4 || div_with_fea_d <= cnt_after_valid) begin
            if (addr_a == 0)
                addr_b = MAX_ADDR - 1;
            else
                addr_b = addr_a - 1;
        end else
            addr_b = 1;
    end
    wire accumulate;
    assign accumulate = (2 < cnt_after_valid && cnt_after_valid < 6);
    wire save;
    assign save = cnt_after_valid >= 6;
    dp_ram #(
        .DATA_W      (9 * BIN_W),
        .ADDR_W      (ADDR_W)
    ) u_dp_ram (
        .clk         (clk),
        .write_en    (i_valid),
        .addr_a      (addr_a),
        .addr_b      (addr_b),
        .i_data      (bin),
        .o_data      (o_data)
    );

    wire [SUM_W - 1 : 0] b_sum;
    reg [SUM_W - 1 : 0] sum;

    assign b_sum = bin_sum(o_data);
    always @(posedge clk) begin
        if(save)
            sum <= sum;
        else if(accumulate)
            sum <= sum + b_sum;
        else
            sum <= b_sum + epsilon;
    end
    
    wire [BIN_W - 1 : 0] dividend;
    assign dividend = (!(cnt_after_valid % 9)) ? o_data[0 +: 20] :
        (cnt_after_valid % 9 == 1) ? o_data[20 +: 20] :
        (cnt_after_valid % 9 == 2) ? o_data[40 +: 20] :
        (cnt_after_valid % 9 == 3) ? o_data[60 +: 20] :
        (cnt_after_valid % 9 == 4) ? o_data[80 +: 20] :
        (cnt_after_valid % 9 == 5) ? o_data[100 +: 20] :
        (cnt_after_valid % 9 == 6) ? o_data[120 +: 20] :
        (cnt_after_valid % 9 == 7) ? o_data[140 +: 20] : o_data[160 +: 20];
    wire [QUO_W - 1 : 0] quotient; 

    div2 #(
        .A_W      (BIN_W),
        .B_W      (SUM_W),
        .O_I_W    (QUO_I),
        // output integer width
        .O_F_W    (QUO_F)
        // output integer width
    ) u_div2 (
        .clk      (clk),
        .a        (dividend),
        .b        (sum),
        .o        (quotient)
    );

    // sqare root of quotient (output): width 8 (int-0, frac-8)
    wire [QUO_W / 2 - 1 : 0] sqrt_q;
    sqrt #(
        .IN_W     (QUO_W),
        .OUT_F    (0)
    ) u_sqrt (
        .clk      (clk),
        .in       (quotient),
        .out      (sqrt_q)
    );
    
    assign fea = {4'b0, sqrt_q};
    
    localparam s_valid_time = div_with_fea_a + FEA_F + 3;
    localparam e_valid_time = s_valid_time + 36;
    assign o_valid = (cnt >= MAX_ADDR && s_valid_time <= cnt_after_valid && cnt_after_valid < e_valid_time && cnt % LINE != 1);
    
    always @(posedge clk) begin
        o_valid_r <= o_valid;
    end
    // function lists
    // bin_sum: sum of 9 bins
    function [21 : 0] bin_sum(input [179 : 0] bin);
        begin
            bin_sum = bin[0 +: 20] 
                + bin[20 +: 20]
                + bin[40 +: 20]
                + bin[60 +: 20]
                + bin[80 +: 20]
                + bin[100 +: 20]
                + bin[120 +: 20]
                + bin[140 +: 20]
                + bin[160 +: 20];
        end
    endfunction
endmodule
