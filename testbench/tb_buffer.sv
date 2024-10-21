`timescale 1ns/1ps

interface buf_if #(
    parameter DATA_W = 32
)(
    input bit clk
);
    logic   [DATA_W - 1 : 0]    i_data = 0;
    logic   [DATA_W - 1 : 0]    o_data = 0;
    logic                       i_valid = 0;
    logic                       o_valid = 0;
    logic                       clear = 0;
    
    clocking cb @(posedge clk);
        default input #1ps output #1ps;
        output  i_data, i_valid, clear;
        input   o_data, o_valid;
    endclocking
endinterface
`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end

module tb_buffer;
    parameter DATA_W = 32;
    parameter DEPTH = 1;
    parameter cycle = 4;
    
    reg clk;
    reg rst;
    buf_if #(.DATA_W(DATA_W)) vif(clk);
    `CLK_GEN(clk, cycle)

    buffer #(
        .DATA_W     (DATA_W),
        .DEPTH      (DEPTH)
    ) u_buffer (
        .clk        (clk),
        // the clock
        .rst        (rst),
        // reset signal
        .i_data     (vif.i_data),
        // input data
        .clear      (vif.clear),
        // clear counter
        .i_valid    (vif.i_valid),
        // input valid signal
        .o_data     (vif.o_data),
        // output data
        // output valid
        .o_valid    (vif.o_valid)
    );

    bit [DATA_W - 1 : 0] d_array [100];
    function void build_phase;
        for(int i = 0; i < 100; i++) begin
            d_array[i] = $random();
        end
    endfunction
    task reset_phase;
        rst = 0;
        repeat(5) @vif.cb;
        rst = 1;

    endtask
    
    bit is_valid = 0;
    task driver;
        for(int i = 0; i < 100; i++) begin
            @vif.cb;
            vif.cb.i_valid <= 1;
            vif.cb.i_data <= d_array[i];
           
        end
    endtask
    int cnt = 0;
    task monitor;
        forever begin
            if(vif.o_valid) begin
                if(vif.o_data != d_array[cnt])
                    $display("ERROR: mismatch data %0d", cnt);
                else
                    $display("INFO: match data %0d", cnt);
                cnt++;
            end
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