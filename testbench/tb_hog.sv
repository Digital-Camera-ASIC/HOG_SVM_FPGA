`timescale 1ns/1ps

`define CLK_GEN(clk, cycle)\
    initial begin\
        clk = 0;\
        forever clk = #(cycle/2.0)  ~clk;\
    end
module tb_hog;
    parameter   PIX_W   = 8; // pixel width
    parameter   MAG_F   = 4;// fraction part of magnitude
    parameter   TAN_I   = 4; // tan width
    parameter   TAN_F   = 16; // tan width
    parameter   BIN_I   = 16; // integer part of bin
    parameter   FEA_I   = 4; // integer part of hog feature
    parameter   FEA_F   = 12; // fractional part of hog feature
    parameter   SW_W    = 11; // slide window width
    parameter   CELL_S  = 10; // Size of cell; default 8x8 pixel and border
    localparam  PIX_N   = CELL_S * CELL_S - 4; // number of cell 
    localparam  IN_W    = PIX_W * PIX_N;
    localparam  FEA_W   = FEA_I + FEA_F;
    localparam  COEF_W  = FEA_W;
    localparam  ROW     = 15;
    localparam  COL     = 7;
    localparam  N_COEF  = ROW * COL; // number of coef in a fetch instruction
    localparam  RAM_DW  = COEF_W * N_COEF;
    localparam  ADDR_W  = 6; // ceil of log2(36)
    reg                       clk;
    reg                       rst;
    reg                       ready;
    wire                      request;
    reg   [IN_W - 1   : 0]    i_data_fetch;
    //// svm if
    // ram interface
    reg   [ADDR_W - 1 : 0]    addr_a;
    reg                       write_en;
    reg   [RAM_DW - 1 : 0]    i_data_a;
    wire  [RAM_DW - 1 : 0]    o_data_a;
    // bias
    reg   [COEF_W - 1 : 0]    bias;
    reg                       b_load;
    // wire info
    wire                      o_valid;
    wire                      is_person;
    wire  [FEA_W - 1  : 0]    result;
    wire  [SW_W - 1   : 0]    sw_id; // slide window index
    initial begin
        addr_a = 0;
        write_en = 0;
        i_data_a = 0;
        bias = 0;
        b_load = 0;
        i_data_fetch = 0;
        ready = 0;
        
    end
    
    `CLK_GEN(clk, 4)
    hog_svm #(
        .PIX_W           (8),
        // pixel width
        .MAG_F           (4),
        // fraction part of magnitude
        .TAN_I           (4),
        // tan width
        .TAN_F           (16),
        // tan width
        .BIN_I           (16),
        // integer part of bin
        .FEA_I           (4),
        // integer part of hog feature
        .FEA_F           (12),
        // fractional part of hog feature
        .SW_W            (11),
        // slide window width
        .CELL_S          (10)
    ) u_hog_svm (
        //// hog if
        .clk             (clk),
        .rst             (rst),
        .ready           (ready),
        .request         (request),
        .i_data_fetch    (i_data_fetch),
        //// svm if
        // ram interface
        .addr_a          (addr_a),
        .write_en        (write_en),
        .i_data_a        (i_data_a),
        .o_data_a        (o_data_a),
        // bias
        .bias            (bias),
        .b_load          (b_load),
        // output info
        .o_valid         (o_valid),
        .is_person       (is_person),
        .result          (result),
        // slide window index
        .sw_id           (sw_id)
    );
    // initial $readmemh(u_hog_svm.u_svm.u_dp_ram2.ram, );
    // initial $readmemh(u_hog_svm.u_svm.bias_r, );
    initial begin
    string file_path_ram = "E:/dai_hoc/CE_project/coef_2.txt";
    $readmemh(file_path_ram, u_hog_svm.u_svm.u_dp_ram2.ram);
    end
    generate;
        genvar i;
        integer j;

//        for(i = 0; i < 3780; i = i + 1) begin
//            initial j = i % 36;
//            initial u_hog_svm.u_svm.u_dp_ram2.ram[j][(i / 36)*COEF_W +: COEF_W] = 3780 - i - 1;
//        end
    endgenerate
    // initial begin
    //     for(integer i = 0; i < MEM_S; i = i + 1) begin
    //         for(integer i = 0; i < MEM_S; i = i + 1) begin
    //         end
    //     end
    //         u_hog_svm.u_svm.u_dp_ram2.ram[i] = $urandom();
    // end  
    class base_item;
        rand bit [IN_W - 1 : 0] my_cell;
    endclass 
    base_item my_item = new();
    task reset_phase;
        rst = 0;
        repeat(5) @(posedge clk);
        rst = 1;
    endtask
    task driver;
        forever begin
            my_item.randomize();
            @(posedge clk);
            #0.01;
            i_data_fetch <= my_item.my_cell;
            ready <= 1;
            wait(request);
        end
    endtask
    task monitor;
        forever begin
            @(posedge clk);
        end
    endtask
    initial begin
//        build_phase;
        reset_phase;
        fork
            driver;
            monitor;
        join_any
        $finish;
    end
    
    
    initial begin
    
    end
endmodule