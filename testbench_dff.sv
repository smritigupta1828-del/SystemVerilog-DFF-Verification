class transaction;
  rand bit din;
  bit dout;
  mailbox mbx;
  
  function transaction copy();
    copy = new();
    copy.din= this.din;
    copy.dout= this.dout;
  endfunction
  
  function void display(input string tag);
    $display("[%s]: DIN: %0b, DOUT: %0b",tag,din,dout);
  endfunction
    
endclass

class generator;
  
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbxref;
  transaction tr;
 // transaction trref;
  event sconext;
  event done;
  int count;
  
  function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
    this.mbx = mbx;
    this.mbxref = mbxref;
    tr= new();
  endfunction
  
  task run();
    repeat(count) begin
      assert(tr.randomize()) else $error("[GEN]: Randomization failed"); 
    //trref=tr;
    
    mbx.put(tr.copy);
    mbxref.put(tr.copy);
      tr.display("GEN");
      @(sconext);
    end
    -> done;
  endtask
  
endclass

//-------------------------------------------

class driver;
  transaction tr;
  mailbox #(transaction) mbx;
  virtual dff_if dif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;    
  endfunction
  
  task reset();
    dif.rst <= 1'b1;
    repeat(5) @(posedge dif.clk);
    dif.rst <= 1'b0;
    @(posedge dif.clk)
    $display("[DRV]: RESET DONE");
  endtask
  
  task run();
    
    forever begin
      
      mbx.get(tr);
      dif.din <= tr.din;
      @(posedge dif.clk);
      tr.display("DRV");
      dif.din <= 1'b0;
      @(posedge dif.clk);
    end
    
  endtask
  
  
endclass

//----------------------------------------------------

class monitor;
  virtual dff_if dif;
  transaction tr;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx= mbx;
  endfunction
  
  task run();
    //mbx= new();
    tr= new();
    forever begin
      repeat(2) @(posedge dif.clk);
    //tr.din <= dif.din;
    tr.dout = dif.dout;
    
    mbx.put(tr);
    tr.display("[MON]");
    end
    
  endtask

endclass

class scoreboard;
  
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbxref;
  transaction trref;
  transaction tr;
  event sconext;
  
  function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
    this.mbx= mbx;
    this.mbxref= mbxref;
  endfunction
  
  task run();
    forever begin
      mbx.get(tr);
      mbxref.get(trref);
      tr.display("SCO");
      tr.display("REF");
      
      if (tr.dout== trref.din) 
        $display("[SCO]: DATA MATCHED");
      
        else $display("[SCO]: Data Mismatched");
      
      ->sconext;
    end
  endtask
  
  
endclass

class environment;
  
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  virtual dff_if dif;
  event next;
  
  mailbox #(transaction) gdmbx;
  mailbox #(transaction) mbxref;
  mailbox #(transaction) msmbx;
  
  function new(dff_if dif);
    gdmbx = new();
    mbxref = new();
    gen = new(gdmbx,mbxref);
    
    drv = new(gdmbx);
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx,mbxref);
    
    this.dif= dif;
    drv.dif = dif;
    mon.dif = dif;
    
    gen.sconext= next;
    sco.sconext= next;
    
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass

module testbench;
  
  dff_if dif;
  dff dut(dif);
  
  initial begin
    dif.clk <= 0;
  end
  
  always #10 dif.clk <= ~dif.clk;
  
  environment env;
  
  initial begin
  env= new(dif);
    env.gen.count =30;
    env.run();
  
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
  
endmodule
