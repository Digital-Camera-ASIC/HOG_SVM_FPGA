// dual port ram
// port a: only write data
// port b: only read data
module dp_ram #(
  parameter   DATA_W  = 180,
  parameter   MEM_S   = 42,
  parameter   ADDR_W  = 6
) (
  input                         clk,
  input                         write_en,
  input       [ADDR_W - 1 : 0]  addr_a,
  input       [ADDR_W - 1 : 0]  addr_b,
  input       [DATA_W - 1 : 0]  i_data,
  output reg  [DATA_W - 1 : 0]  o_data
);
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