// controls for the big bayesian machine 

module banzAI #(
  )(
    ADAM_SEQ.Slave seq_port,
    AXI_LITE.Slave axi_slave[2], 
    AXI_LITE.Master axi_master
  ) ;
  logic clk ; 
  assign clk = seq_port.clk;
  logic rst_n ;
  assign rst_n = ~seq_port.rst;

  
  
endmodule