`timescale 1ns/1ps
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
module tb_div;
    parameter   A_W     = 8,
       B_W     = 8,
       O_I_W   = 4, // output integer width
       O_F_W   = 16; // output integer width
    localparam  O_W     = O_I_W + O_F_W; // output width
    reg clk;
    int seed = 50;
    `CLK_GEN(clk, 2)
    class item;
        rand logic [A_W - 1 : 0] a;
        rand logic [B_W - 1:0] b;
    endclass
    logic [A_W - 1 : 0] a;
    logic [B_W - 1:0] b;
    logic [O_W - 1:0] o;
    logic i_sign_diff;
    div #(
    ) u_div (
        .clk      (clk),
        .a        (a),
        .b        (b),
        .i_sign_diff (i_sign_diff),
        .o        (o)
    );
    initial begin
    fork
        driver;
        monitor;
    join
    end
    int temp_a [$];
    int temp_b [$];
    task driver;
        item myItem = new();
        myItem.srandom(seed);
        for(int i = 0; i < 100; i++) begin
            #0.01;
            myItem.randomize();
            temp_a.push_back(myItem.a);
            temp_b.push_back(myItem.b);
            a <= temp_a[temp_a.size - 1];
            b <= temp_b[temp_b.size - 1];
            i_sign_diff <= i[0];
            @(posedge clk);
        end
    endtask
    real actual;
    task monitor;
        real gm;
        int cnt_pass = 0;
        int cnt_failed = 0;
        repeat(12) @(posedge clk);
        
        for(int i = 0; i < 100; i++) begin
            #0.1;
            actual = (o[19]) ? -o : o;
            actual = actual / 2**16;
            gm = temp_a.pop_front() * 1.0 / temp_b.pop_front();
            $display("actual - gm - q (%f, %f, %f)", actual, gm, actual - gm);
            if (actual - gm < 0.1 || actual - gm > -0.1)
                cnt_pass++;
            else
                cnt_failed++;
            @(posedge clk);
        end
        $display("TEST PASS:%20d\nTEST FAIL:%20d",cnt_pass, cnt_failed);
    endtask
endmodule