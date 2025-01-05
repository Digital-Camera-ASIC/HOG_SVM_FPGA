`timescale 1ns/1ps
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
module tb_sqrt;
    
    reg clk;
    
    `CLK_GEN(clk, 2)

    logic [17:0] in;
    logic [14:0] out;
    sqrt #(
        .IN_W     (18),
        .OUT_F    (6)
    ) u_sqrt (
        .clk      (clk),
        .in       (in),
        .out      (out)
    );
    initial begin
    fork
        driver;
        monitor;
    join
    end
    int temp [$];
    task driver;
        for(int i = 0; i < 100; i++) begin
            #0.01;
            temp.push_back($urandom() % 130050);
//            $display("temp[temp.size - 1] %d",temp[temp.size - 1]);
            in <= temp[temp.size - 1];
            @(posedge clk);
        end
    endtask
    real actual;
    task monitor;
        real gm;
        repeat(15) @(posedge clk);

        for(int i = 0; i < 100; i++) begin
            #0.1;
            actual = out;
            actual = actual / 2**6;
            gm = $sqrt(temp.pop_front());
            $display("actual - gm - q (%f, %f, %f)", actual, gm, actual - gm);
            @(posedge clk);
        end
    endtask
endmodule