//// Single-Port Block RAM Write-First Mode
// Single-Port Block RAM Write-First Mode (recommended template)
// File: rams_sp_wf.v
module ram_sp_wf (clk, we, en, addr, di, dout);
input clk; 
input we; 
input en;
input [9:0] addr; 
input [31:0] di; 
output [31:0] dout;
reg [31:0] RAM [1023:0];
reg [63:0] dout;

always @(posedge clk)
begin
  if (en)
  begin
    if (we)
      begin
        RAM[addr] <= di;
        dout <= di;
      end
   else
    dout <= RAM[addr];
  end
end
endmodule

//module ram_sp_wf  #(
//    parameter DATA_W    = 32,  // Data Width
//    parameter DF        = {DATA_W{1'b1}}  // default value 
//) ( 
//    input                           clk,
//    input                           w_en, // write enable
//    input       [DATA_W - 1 : 0]    i_data, // data input
//    output reg  [DATA_W - 1 : 0]    o_data  // data output
//);
//    (* ram_style = "distributed" *) reg [DATA_W - 1 : 0]  RAM;
//    always @(posedge clk) begin
//        /*if(!rst) begin
//            RAM <= DF;
//            o_data <= DF;
//        end else */if (w_en) begin 
//            RAM <= i_data; 
//            o_data <= i_data; 
//        end else 
//            o_data <= RAM; 
//    end 
//endmodule