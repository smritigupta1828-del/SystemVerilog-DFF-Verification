interface dff_if;
  logic din;
  logic rst;
  logic clk;
  logic dout;
endinterface

module dff(dff_if dif);
  
  always @(posedge dif.clk)
    if(dif.rst ==1)
      dif.dout <= 1'b0;
  else
    dif.dout<= dif.din; 
  
endmodule
