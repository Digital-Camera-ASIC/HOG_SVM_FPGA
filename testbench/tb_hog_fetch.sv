`timescale 1ns/1ps
class item_f;
    rand bit [7:0] pixel[96];
    bit [8*96 - 1 : 0] data;
    constraint temp {
        foreach(pixel[i])
            pixel[i] == i;
    };
    function new;
    endfunction
    function void post_randomize();
        data = 0;
        for(int i = 95; i >= 0; i--)
            data = (data << 8) | pixel[i];
    endfunction
endclass
interface hog_fet_if(
    input bit clk
);
    logic   [8*96 - 1 : 0]    data = 0;
    logic               ready = 0;
    logic               request = 0;
    clocking cb @(posedge clk);
        default input #1ps output #1ps;
        output  data, ready;
    endclocking
endinterface
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
module tb_hog_fetch;
    parameter cycle = 4;
    
    reg clk;
    reg rst;
    hog_fet_if vif(clk);
    `CLK_GEN(clk, cycle)
    hog_fetch #(
        .PIX_W      (8),
        .CELL_S     (10)
        // Size of cell, default 8x8 pixel and border
    ) u_hog_fetch (
        .clk        (clk),
        .rst        (rst),
        // fifo if
        .ready      (vif.ready),
        .request    (vif.request),
        .i_data     (vif.data),
        // hog if
        .i_valid    (i_valid),
        // top, bot left, right
        .o_data     (o_data)
    );
    item_f obj;
    function void build_phase;
        obj = new;
        obj.randomize();
    endfunction
    task reset_phase;
        rst = 0;
        repeat(5) @vif.cb;
        rst = 1;
    endtask
    
    task driver;
        for(int i = 0; i < 200; i++) begin
            @vif.cb;
            if(i > 63 && i < 72)
                vif.cb.ready <= 0;
            else
                vif.cb.ready <= 1;
            
            vif.cb.data <= obj.data;
            obj.randomize();
            
        end
    endtask
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