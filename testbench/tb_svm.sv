`timescale 1ns/1ps
module tb_svm;
    reg clk, rst;
    reg i_valid;
    bit [32 * 9 - 1 : 0] fea [4];
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
    end
    initial begin
        wait(!i_valid);
        wait(i_valid);
        for(int i = 0; i < 4000; i++) begin
            foreach (fea[j]) begin
                fea[j] = {9{i[31:0]}}; 
            end
            @(posedge clk);
        end
        $finish();
    end
    svm #(
        .FEA_I        (4),
        // integer part of hog feature
        .FEA_F        (28),
        // fractional part of hog feature
        .SW_W         (11)
        // slide window width
    ) u_svm (
        .clk          (clk),
        .rst          (rst),
        .fea_a        (fea[0]),
        .fea_b        (fea[1]),
        .fea_c        (fea[2]),
        .fea_d        (fea[3]),
        .i_valid      (i_valid),
        .is_person    (is_person),
        .o_valid      (o_valid),
        .sw_id        (sw_id)
        // slide window index
    );
endmodule