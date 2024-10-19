`timescale 1ns/1ps
class item;
    rand bit [31:0] data [9];
    constraint limit {
        data.sum() < 23079;
    }
    function new;
    endfunction
endclass
interface hog_fea_if #(
    parameter DATA_W = 32
)(
    input bit clk
);
    logic   [DATA_W - 1 : 0]    bin = 0;
    logic                       i_valid = 0;
    logic                       o_valid = 0;
    logic   [12:0]              addr_fw = 0;
    logic   [12:0]              bid = 0;
    logic   [DATA_W - 1 : 0]    fea_a = 0;
    logic   [DATA_W - 1 : 0]    fea_b = 0;
    logic   [DATA_W - 1 : 0]    fea_c = 0;
    logic   [DATA_W - 1 : 0]    fea_d = 0;

    clocking cb @(posedge clk);
        default input #1ps output #1ps;
        output  bin, i_valid, addr_fw;
        input   o_valid, bid, fea_a, fea_b, fea_c, fea_d;
    endclocking
endinterface
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module tb_hog_feature_gen;
    parameter DATA_W = 288;
    parameter DEPTH = 1;
    parameter cycle = 4;
    
    reg clk;
    reg rst;
    hog_fea_if #(.DATA_W(DATA_W)) vif(clk);
    `CLK_GEN(clk, cycle)

    hog_feature_gen #(
        .ADDR_W     (13),
        // address width of cells
        .BIN_I      (16),
        // integer part of bin
        .BIN_F      (16),
        // fractional part of bin
        .BID_W      (13),
        // block id width
        .FEA_I      (4),
        // integer part of hog feature
        // fractional part of hog feature
        .FEA_F      (28)
    ) u_hog_feature_gen (
        .clk        (clk),
        .rst        (rst),
        .addr_fw    (vif.addr_fw),
        .address    (5),  
        .bin        (vif.bin),
        .i_valid    (vif.i_valid),
        .bid        (vif.bid),
        .fea_a      (vif.fea_a),
        .fea_b      (vif.fea_b),
        .fea_c      (vif.fea_c),
        .fea_d      (vif.fea_d),
        .o_valid    (vif.o_valid)
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