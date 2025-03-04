// controls for the big bayesian machine 
`include "adam/macros.svh"

module banzAI #(
  `ADAM_CFG_PARAMS
  )(
    ADAM_SEQ.Slave seq_port,
    AXI_LITE.Slave axi_slave[2], 
    AXI_LITE.Master axi_master
  ) ;

  // pwr controler 
  PWR_CTRL #(
    .reg_num(16), 
    `ADAM_CFG_PARAMS_MAP
  ) pwr_ctrl(
    .seq_port(seq_port),
    .axi_port(axi_slave[0]), 
    .axi_master(axi_master)
  );
  
  // chip controler 
  chip_control #(
    `ADAM_CFG_PARAMS_MAP
  ) chip_ctrl(
    .seq_port(seq_port),
    .axi_port(axi_slave[1])
  );

endmodule