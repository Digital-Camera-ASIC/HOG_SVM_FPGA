`timescale 1ns/1ps
class mag_item;
    rand bit [31:0] pixel;
    function new;
    endfunction
endclass
interface mag_cal_if(
    input bit clk
);
    logic   [31 : 0]    pixel = 0;
    logic               i_valid = 0;
    logic   [26 : 0]    bin[9];
    logic               o_valid;

    clocking cb @(posedge clk);
        default input #1ps output #1ps;
        output  pixel, i_valid;
        input   bin, o_valid;
    endclocking
endinterface
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end


module tb_mag_cal_sbs;

    parameter cycle = 4;
    
    reg clk, rst;
    `CLK_GEN(clk, cycle)

    mag_cal_if vif(clk);

    mag_cal_sbs u_mag_cal_sbs (
        .clk        (clk),
        .rst        (rst),
        .pixel      (vif.pixel),
        .bin0       (vif.bin[0]),
        .bin20      (vif.bin[1]),
        .bin40      (vif.bin[2]),
        .bin60      (vif.bin[3]),
        .bin80      (vif.bin[4]),
        .bin100     (vif.bin[5]),
        .bin120     (vif.bin[6]),
        .bin140     (vif.bin[7]),
        .bin160     (vif.bin[8])
    );
    
    mag_item obj;
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
        for(int i = 0; i < 10; i++) begin
            vif.cb.i_valid <= 1;
            vif.cb.pixel <= obj.pixel;
            obj.randomize();
            @vif.cb;
        end
        repeat(3) begin
            vif.cb.i_valid <= 0;
            @vif.cb;
        end
        for(int i = 0; i < 10; i++) begin
            vif.cb.i_valid <= 1;
            vif.cb.pixel <= obj.pixel;
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