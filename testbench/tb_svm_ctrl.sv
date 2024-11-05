`timescale 1ns/1ps
module tb_svm_ctrl;

    reg clk, rst;
    reg i_valid;

    initial begin
        clk <= 0;
        forever #2 clk <= ~clk;
    end
    initial begin
        rst <= 1;
        @(posedge clk);
        #0.1;
        rst <= 0;
        repeat(5) @(posedge clk);
        #0.1;
        rst <= 1;
    end
    initial begin
        i_valid <= 0;
        wait(!rst);
        wait(rst);
        @(posedge clk);
        #0.1;
        i_valid <= 1;
        repeat(1130/2) @(posedge clk);
        #0.1;
        i_valid <= 0;
        repeat(3) @(posedge clk);
        #0.1;
        i_valid <= 1;
        
    end
    svm_ctrl #(
        // slide window width
        .SW_W       (11)
    ) u_svm_ctrl (
        .clk        (clk),
        .rst        (rst),
        .i_valid    (i_valid),
        .o_valid    (o_valid),
        // slide window index
        .sw_id      (sw_id)
    );
endmodule