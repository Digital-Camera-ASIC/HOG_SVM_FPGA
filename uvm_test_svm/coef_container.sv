class coef_container extends uvm_object;
  // Mảng chứa các giá trị coef
  logic [287:0] coef [420];

  // Constructor
  function new(string name = "coef_container");
      super.new(name);
  endfunction

  // Phương thức để in mảng (tuỳ chọn)
  function void display();
      foreach (coef[i]) begin
        $display("coef[%0d] = %h", i, coef[i]);
      end
  endfunction
endclass