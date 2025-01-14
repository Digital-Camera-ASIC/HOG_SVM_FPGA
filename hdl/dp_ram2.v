// dual port ram
// port a: write - read data
// port b: only read data
module dp_ram2 #(
  parameter   DATA_W  = 180,
  parameter   ADDR_W  = 6
) (
  input                         clk,
  input                         write_en,
  input       [ADDR_W - 1 : 0]  addr_a,
  input       [ADDR_W - 1 : 0]  addr_b,
  input       [DATA_W - 1 : 0]  i_data,
  output reg  [DATA_W - 1 : 0]  o_data
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
    if (write_en)   
      ram[addr_a] <= i_data;
  end
  // output port
  always @(posedge clk) begin 
    o_data <= ram[addr_b];
  end
endmodule