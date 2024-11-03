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
        .ADDR_W      (10),
        .PIX_W       (8),
        // pixel width
        .PIX_N       (96),
        .MAG_I       (9),
        // integer part of magnitude
        .MAG_F       (16),
        // fraction part of magnitude
        .TAN_W       (19),
        // tan width
        .BIN_I       (16),
        // integer part of bin
        // fractional part of bin
        .BIN_F       (16)
    ) u_hog_fetch (
        .clk         (clk),
        .rst         (rst),
        .ready       (vif.ready),
        .i_data      (vif.data),
        .request     (),
        .o_valid     (),
        .addr_fw     (),
        .address     (),
        .bin         ()
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
            if(i % 3)
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