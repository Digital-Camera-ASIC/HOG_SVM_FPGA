`timescale 1ns/1ps
class mag_item;
    rand bit [7:0] top;
    rand bit [7:0] bottom;
    rand bit [7:0] left;
    rand bit [7:0] right;
    bit [31:0] pixel;
    function void post_randomize;
        pixel = {top, bottom, left, right};
    endfunction
    function new;
    endfunction
endclass
interface mag_cal_if(
    input bit clk
);
    logic   [31 : 0]    pixel = 0;
    logic               i_valid = 0;
    logic   [19 : 0]    bin[9];
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

    wire [12 : 0] magnitude_w;
    wire [11 : 0] tan_w;
    wire mag_cal_valid;
    mag_cal #(
    .PIX_W        (8),
    // pixel width
    .MAG_F        (4),
    // fraction part of magnitude
    .TAN_I        (4),
    // tan integer (signed number)
    .TAN_F        (8)
) u_mag_cal (
    .clk          (clk),
    .rst          (rst),
    .i_valid      (vif.i_valid),
    .pixel        (vif.pixel),
    .magnitude    (magnitude_w),
    .tan          (tan_w),
    .o_valid      (mag_cal_valid)
);
    bin_cal #(
    .TAN_W        (12),
    .MAG_I        (9),
    .MAG_F        (4),
    .BIN_I        (16)
    // integer part of bin
    ) u_bin_cal (
        .clk          (clk),
        .rst          (rst),
        .i_valid      (mag_cal_valid),
        .magnitude    (magnitude_w),
        .tan          (tan_w),
        .o_valid      (vif.o_valid),
        .bin          ({
            vif.bin[8],
            vif.bin[7],
            vif.bin[6],
            vif.bin[5],
            vif.bin[4],
            vif.bin[3],
            vif.bin[2],
            vif.bin[1],
            vif.bin[0]
            })
    );

    mag_item obj;
    mag_item myInput [$];
    
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
        for(int i = 0; i < 64; i++) begin
            myInput.push_back(obj);
            vif.cb.i_valid <= 1;
            vif.cb.pixel <= obj.pixel;
            obj = new;
            obj.randomize();
            @vif.cb;
        end
        repeat(3) begin
            vif.cb.i_valid <= 0;
            @vif.cb;
        end
        for(int i = 0; i < 63; i++) begin
            vif.cb.i_valid <= 1;
            vif.cb.pixel <= obj.pixel;
            obj.randomize();
            @vif.cb;
        end
    endtask

    real magnitude;
    real tan;
    real act_magnitude;
    real act_tan;
    function real abs(input real a);
        if(a < 0)
            return -a;
        else
            return a;
    endfunction
    int top, bot, left, right;
    function void predictor;
        top = myInput[0].top;
        bot = myInput[0].bottom;
        left = myInput[0].left;
        right = myInput[0].right;
        magnitude = $sqrt((bot - top) ** 2 + (left - right) ** 2);
        tan = (right - left) * 1.0 / (bot - top);
        
        myInput.pop_front();
        while(tan >= 8)
           tan = tan - 8;
        while(tan <= -8)
           tan = tan + 8;
        act_magnitude = act_magnitude / 2**4;
        act_tan = act_tan / 2**8;
        
    endfunction
    function bit compare;
        if(abs(act_magnitude - magnitude) > 0.1)
            return 0;
        if(abs(act_tan - tan) > 0.1)
            return 0;
        return 1;
    endfunction
    int cnt_pass = 0;
    int cnt_fail = 0;
    task monitor;
        bit valid;
        forever begin
            @vif.cb;
            valid = vif.cb.o_valid;
            if(valid)begin
                if(myInput.size) begin
                    act_magnitude = 0;
                    act_tan = 0;
                    
                    predictor;
                    if(compare()) cnt_pass++;
                    else begin
                        cnt_fail++;
                        // for debugging
                        $display("time: %t", $time);
                        $display("top: %0d", top);
                        $display("bot: %0d", bot);
                        $display("left: %0d", left);
                        $display("right: %0d", right);
                        $display("magnitude: %0f", magnitude);
                        $display("tan: %0f", tan);
                        $display("act_magnitude: %0f", act_magnitude);
                        $display("act_tan: %0f", act_tan);
                    end
                end
            end
        end
    endtask
    function void report_phase;
//        $display("TEST PASS:%0d\nTEST FAIL:%0d",cnt_pass, cnt_fail);
    endfunction
    initial begin
        build_phase;
        reset_phase;
        fork
            driver;
            monitor;
        join_any
        #100;
        report_phase;
        $finish;
    end
endmodule