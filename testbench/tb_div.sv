`timescale 1ns/1ps
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
module tb_div;
    
    reg clk;
    int seed = 50;
    `CLK_GEN(clk, 2)

    logic [8:0] a;
    logic [8:0] b;
    logic signed [19:0] o;
    div #(
        .A_W      (9),
        .B_W      (9),
        .O_I_W    (4),
        // output integer width
        .O_F_W    (16)
        // output integer width
    ) u_div (
        .clk      (clk),
        .a        (a),
        .b        (b),
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
        for(int i = 0; i < 100; i++) begin
            #0.01;
            temp_a.push_back($random(seed) % 256);
            temp_b.push_back($random(seed) % 256);
//            temp_a.push_back(-157);
//            temp_b.push_back(10);
//            $display("temp_a[temp_a.size - 1] %d",temp_a[temp_a.size - 1]);
//            $display("temp_b[temp_b.size - 1] %d",temp_b[temp_b.size - 1]);
            a <= temp_a[temp_a.size - 1];
            b <= temp_b[temp_b.size - 1];
            @(posedge clk);
        end
    endtask
    real actual;
    task monitor;
        real gm;
        int cnt_pass = 0;
        int cnt_failed = 0;
        repeat(1) @(posedge clk);
        
        for(int i = 0; i < 100; i++) begin
            #0.1;
            if(o < 0) actual = o - 16;
            else actual = o;
            actual = actual / 2**8;
            gm = temp_a.pop_front() * 1.0 / temp_b.pop_front();
           while(gm >= 8)
               gm = gm - 8;
           while(gm <= -8)
               gm = gm + 8;
//            $display("actual - gm - q (%f, %f, %f)", actual, gm, actual - gm);
            if (actual - gm < 0.1 || actual - gm > -0.1)
                cnt_pass++;
            else
                cnt_failed++;
            @(posedge clk);
        end
        $display("TEST PASS:%20d\nTEST FAIL:%20d",cnt_pass, cnt_failed);
    endtask
endmodule