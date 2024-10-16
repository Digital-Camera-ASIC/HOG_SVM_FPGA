`timescale 1ns/1ps
class item;
    rand bit [31:0] data [9];
    constraint limit {
        foreach (data[i])
            data[i][31:16] < 23079;
        data.sum() < 23079;
    }
    function new;
    endfunction
endclass
interface normalize_if(
    input bit clk
);
    logic   [288 - 1 : 0]    i_data[4];
    logic   [288 - 1 : 0]    o_data[4];
    logic                    i_valid = 0;
    logic                    o_valid = 0;
    logic                    clear = 0;
    logic   [13 - 1 : 0]     bid = 0;
    clocking cb @(posedge clk);
        default input #1ps output #1ps;
        output  i_data, i_valid, clear;
        input   o_data, o_valid, bid;
    endclocking
endinterface
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module tb_normalize;
    parameter cycle = 4;
    reg clk;
    reg rst;
    normalize_if vif(clk);
    `CLK_GEN(clk, cycle);


    normalize u_normalize (
        .clk        (clk),
        .rst        (rst),
        .bin_a      (vif.i_data[0]),
        .bin_b      (vif.i_data[1]),
        .bin_c      (vif.i_data[2]),
        .bin_d      (vif.i_data[3]),
        .i_valid    (vif.i_valid),
        .fea_a      (vif.o_data[0]),
        .fea_b      (vif.o_data[1]),
        .fea_c      (vif.o_data[2]),
        .fea_d      (vif.o_data[3]),
        .bid        (vif.bid),
        .o_valid    (vif.o_valid)
    );
    item item_a;
    item item_b;
    item item_c;
    item item_d;
    function void build_phase;
        item_a = new();
        item_a.randomize();
        item_b = new();
        item_b.randomize();
        item_c = new();
        item_c.randomize();
        item_d = new();
        item_d.randomize();
    endfunction
    task reset_phase;
        rst = 0;
        repeat(5) @vif.cb;
        rst = 1;

    endtask
    
    task driver;
        for(int i = 0; i < 1; i++) begin
            vif.cb.i_valid <= 1;
            vif.cb.i_data[0] <= {
                item_a.data[0], 
                item_a.data[1],
                item_a.data[2],
                item_a.data[3],
                item_a.data[4],
                item_a.data[5],
                item_a.data[6],
                item_a.data[7],
                item_a.data[8]
            };
            vif.cb.i_data[1] <= {
                item_b.data[0], 
                item_b.data[1],
                item_b.data[2],
                item_b.data[3],
                item_b.data[4],
                item_b.data[5],
                item_b.data[6],
                item_b.data[7],
                item_b.data[8]
            };
            vif.cb.i_data[2] <= {
                item_c.data[0], 
                item_c.data[1],
                item_c.data[2],
                item_c.data[3],
                item_c.data[4],
                item_c.data[5],
                item_c.data[6],
                item_c.data[7],
                item_c.data[8]
            };
            vif.cb.i_data[3] <= {
                item_d.data[0], 
                item_d.data[1],
                item_d.data[2],
                item_d.data[3],
                item_d.data[4],
                item_d.data[5],
                item_d.data[6],
                item_d.data[7],
                item_d.data[8]
            };
            $display("---------------");
            foreach (item_a.data[i])
                $display("%d", item_a.data[i]);
            foreach (item_b.data[i])
                $display("%d", item_b.data[i]);
            foreach (item_c.data[i])
                $display("%d", item_c.data[i]);
            foreach (item_d.data[i])
                $display("%d", item_d.data[i]);
            item_a.randomize();
            item_b.randomize();
            item_c.randomize();
            item_d.randomize();
            @vif.cb;
        end
    endtask
    int cnt = 0;
    task monitor;
        forever begin
            @vif.cb;
        end
    endtask
    initial begin
        build_phase;
        reset_phase;
        fork
            driver;
            monitor;
        join_any
        $finish;
    end
endmodule