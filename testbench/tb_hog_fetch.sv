`timescale 1ns/1ps
class ;
    rand bit [7:0] pixel[96];
    bit [8*96 - 1 : 0] data;
    function new;
    endfunction
    function void post_randomize();
        data = 0;
        for(int i = 0; i < 96; i++)
            data = (data << 8) | pixel;
    endfunction
endclass
interface hog_fet_if(
    input bit clk
);
    logic   [8*96 - 1 : 0]    data = 0;
    logic               ready = 0;

    clocking cb @(posedge clk);
        default input #1ps output #1ps;
        output  data, i_valid;
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
        .MAX_ADDR    (1199),
        .PIX_W       (8),
        .PIX_N       (96)
    ) u_hog_fetch (
        .clk         (clk),
        .rst         (rst),
        .ready       (ready),
        .i_data      (i_data),
        .request     (),
        .o_valid     (),
        .addr_fw     ()
    );

    item obj;
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
            vif.cb.i_valid <= 1;
            vif.cb.addr_fw <= 1;
            vif.cb.bin <= {
                obj.data[8],
                obj.data[7],
                obj.data[6],
                obj.data[5],
                obj.data[4],
                obj.data[3],
                obj.data[2],
                obj.data[1],
                obj.data[0]
                };
            obj.randomize();
            @vif.cb;
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