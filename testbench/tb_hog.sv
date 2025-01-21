`timescale 1ns/1ps
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
module tb_hog;
    reg clk;
    reg rst;
    reg [31 : 0] i_data;
    reg ready;
    initial begin
        i_data = 0;
        ready = 0;
    end
    wire [11 : 0] fea;
    wire o_valid;
    `CLK_GEN(clk, 4)
    hog #(
    .PIX_W      (8),
    // pixel width
    .MAG_F      (4),
    // fraction part of magnitude
    .TAN_I      (4),
    // tan width
    .TAN_F      (8),
    // tan width
    .BIN_I      (16),
    // integer part of bin
    .FEA_I      (4),
    // integer part of hog feature
    .FEA_F      (8)
    // fractional part of hog feature
) u_hog (
    .clk        (clk),
    .rst        (rst),
    .ready      (ready),
    .i_data     (i_data),
    .request    (request),
    .fea        (fea),
    .o_valid    (o_valid)
);
    bit [7:0] top;
    bit [7:0] bot;
    bit [7:0] left;
    bit [7:0] right;
    task reset_phase;
        rst = 0;
        repeat(5) @(posedge clk);
        rst = 1;
    endtask
    task driver;
        top = 'h83;
        bot = 'h78;
        left = 'h26;
        right = 'h57;
        repeat (64) begin
            @(posedge clk);
            #0.01;
            i_data <= {top, bot, left, right};
            ready <= 1;
        end
        //
        top = 0;
        bot = 9;
        left = 0;
        right = 6;
        repeat (64) begin
            @(posedge clk);
            #0.01;
            i_data <= {top, bot, left, right};
            ready <= 1;
        end
        repeat (64*38) begin
            @(posedge clk);
            #0.01;
            i_data <= {top, bot, left, right};
            ready <= 1;
        end
        
        top = 0;
        bot = 48;
        left = 0;
        right = 45;
        repeat (64) begin
            @(posedge clk);
            #0.01;
            i_data <= {top, bot, left, right};
            ready <= 1;
        end
        //
        top = 0;
        bot = 49;
        left = 0;
        right = 46;
        repeat (64) begin
            @(posedge clk);
            #0.01;
            i_data <= {top, bot, left, right};
            ready <= 1;
        end
        forever begin
            @(posedge clk);
            #0.01;
            i_data <= {top, bot, left, right};
            ready <= 1;
        end
    endtask
    task monitor;
        forever begin
            @(posedge clk);
        end
    endtask
    initial begin
//        build_phase;
        reset_phase;
        fork
            driver;
            monitor;
        join_any
        $finish;
    end
endmodule