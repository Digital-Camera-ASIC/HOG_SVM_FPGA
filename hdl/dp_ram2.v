// dual port ram
// port a: write - read data
// port b: only read data
module dp_ram2 #(
  parameter   DATA_W  = 12,
  parameter   ADDR_W  = 5
) (
  input                         clk,
  input       [ADDR_W - 1 : 0]  addr_a,
  input                         write_en,
  input       [DATA_W - 1 : 0]  i_data,
  output reg  [DATA_W - 1 : 0]  o_data_a,
  input       [ADDR_W - 1 : 0]  addr_b,
  output reg  [DATA_W - 1 : 0]  o_data_b
);
  localparam MEM_S = 2 ** ADDR_W;
  reg [DATA_W - 1 : 0] ram [MEM_S - 1 : 0];
  integer i;
  initial begin
    for(i = 0; i < MEM_S; i = i + 1)
      ram[i] = 0;
  end  
  // input port
  always @(posedge clk) begin 
    if (write_en) begin
      ram[addr_a] <= i_data;
      o_data_a <= i_data;
    end else begin
      o_data_a <= ram[addr_a];
    end
  end
  // output port
  always @(posedge clk) begin 
    o_data_b <= ram[addr_b];
  end
endmodule