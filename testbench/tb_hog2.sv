`timescale 1ns/1ps

`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module tb_hog2;
    parameter   PIX_W   = 8; // pixel width
    parameter   MAG_F   = 4;// fraction part of magnitude
    parameter   TAN_I   = 4; // tan width
    parameter   TAN_F   = 16; // tan width
    parameter   BIN_I   = 16; // integer part of bin
    parameter   FEA_I   = 4; // integer part of hog feature
    parameter   FEA_F   = 12; // fractional part of hog feature
    localparam  FEA_W   = FEA_I + FEA_F;
    localparam  IN_W    = PIX_W * 4;
    reg                       clk;
    reg                       rst;
    reg                       i_valid;
    wire   [IN_W - 1   : 0]    i_data;
    wire  [FEA_W - 1  : 0]    fea;
    wire                      o_valid;
    bit [PIX_W - 1 : 0] top, bot, left, right;
    assign i_data = {top, bot, left, right};
    `CLK_GEN(clk, 4)
    initial begin
        rst = 0;
        repeat(5) @(posedge clk);
        rst = 1;
    end
    initial begin
        i_valid = 0;
        top = 'd0;
        bot = 'd0;
        left = 'd0;
        right = 'd0;
        wait(rst);

        @(posedge clk);
        i_valid = 1;
        top = 'd131;
        bot = 'd120;
        left = 'd38;
        right = 'd87;

        @(posedge clk);
        i_valid = 1;
        top = 'd172;
        bot = 'd2;
        left = 'd215;
        right = 'd133;
        @(posedge clk);
        i_valid = 1;
        top = 'd155;
        bot = 'd52;
        left = 'd213;
        right = 'd31;
        @(posedge clk);
        i_valid = 1;
        top = 'd35;
        bot = 'd187;
        left = 'd45;
        right = 'd124;
        @(posedge clk);
        i_valid = 1;
        top = 'd52;
        bot = 'd90;
        left = 'd210;
        right = 'd132;
        @(posedge clk);
        i_valid = 1;
        top = 'd109;
        bot = 'd100;
        left = 'd115;
        right = 'd243;
        @(posedge clk);
        i_valid = 1;
        top = 'd151;
        bot = 'd184;
        left = 'd155;
        right = 'd65;
        @(posedge clk);
        i_valid = 1;
        top = 'd42;
        bot = 'd114;
        left = 'd45;
        right = 'd227;
        @(posedge clk);
        i_valid = 1;
        top = 'd214;
        bot = 'd208;
        left = 'd31;
        right = 'd154;
        @(posedge clk);
        i_valid = 1;
        top = 'd226;
        bot = 'd4;
        left = 'd109;
        right = 'd101;
        forever begin
            @(posedge clk);
            i_valid = 1;
            top = 'd0;
            bot = 'd0;
            left = 'd0;
            right = 'd0;
        end
    end
    hog #(
        .PIX_W      (PIX_W),
        // pixel width
        .MAG_F      (MAG_F),
        // fraction part of magnitude
        .TAN_I      (TAN_I),
        // tan width
        .TAN_F      (TAN_F),
        // tan width
        .BIN_I      (BIN_I),
        // integer part of bin
        .FEA_I      (FEA_I),
        // integer part of hog feature
        .FEA_F      (FEA_F)
    ) u_hog (
        .clk        (clk),
        .rst        (rst),
        .i_valid    (i_valid),
        .i_data     (i_data),
        .fea        (fea),
        .o_valid    (o_valid)
    );
endmodule