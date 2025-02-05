`include "adam/macros.svh"

module  #(
    `ADAM_CFG_PARAMS
) (
    // seq 
    input logic clk_i, 
    input logic rst_i,

    // axi slave[0]
    input logic [31:0] axi_slave_0_awaddr_i,
    input logic [2:0] axi_slave_0_awprot_i,
    input logic axi_slave_0_awvalid_i,
    output logic axi_slave_0_awready_o,
    input logic [31:0] axi_slave_0_wdata_i,
    input logic [3:0] axi_slave_0_wstrb_i,
    input logic axi_slave_0_wvalid_i,
    output logic axi_slave_0_wready_o,
    output logic axi_slave_0_bresp_o,
    output logic axi_slave_0_bvalid_o,
    input logic axi_slave_0_bready_i,
    input logic [31:0] axi_slave_0_araddr_i,
    input logic [2:0] axi_slave_0_arprot_i,
    input logic axi_slave_0_arvalid_i,
    output logic axi_slave_0_arready_o,
    output logic [31:0] axi_slave_0_rdata_o,
    output logic [1:0] axi_slave_0_rresp_o,
    output logic axi_slave_0_rvalid_o,
    input logic axi_slave_0_rready_i,

    // axi slave[1]
    input logic [31:0] axi_slave_1_awaddr_i,
    input logic [2:0] axi_slave_1_awprot_i,
    input logic axi_slave_1_awvalid_i,
    output logic axi_slave_1_awready_o,
    input logic [31:0] axi_slave_1_wdata_i,
    input logic [3:0] axi_slave_1_wstrb_i,
    input logic axi_slave_1_wvalid_i,
    output logic axi_slave_1_wready_o,
    output logic axi_slave_1_bresp_o,
    output logic axi_slave_1_bvalid_o,
    input logic axi_slave_1_bready_i,
    input logic [31:0] axi_slave_1_araddr_i,
    input logic [2:0] axi_slave_1_arprot_i,
    input logic axi_slave_1_arvalid_i,
    output logic axi_slave_1_arready_o,
    output logic [31:0] axi_slave_1_rdata_o,
    output logic [1:0] axi_slave_1_rresp_o,
    output logic axi_slave_1_rvalid_o,
    input logic axi_slave_1_rready_i,

    // axi master
    output logic [31:0] axi_master_awaddr_o,
    output logic [2:0] axi_master_awprot_o,
    output logic axi_master_awvalid_o,
    input logic axi_master_awready_i,
    output logic [31:0] axi_master_wdata_o,
    output logic [3:0] axi_master_wstrb_o,
    output logic axi_master_wvalid_o,
    input logic axi_master_wready_i,
    input logic [31:0] axi_master_bresp_i,
    input logic axi_master_bvalid_i,
    output logic axi_master_bready_o,
    output logic [31:0] axi_master_araddr_o,
    output logic [2:0] axi_master_arprot_o,
    output logic axi_master_arvalid_o,
    input logic axi_master_arready_i,
    input logic [31:0] axi_master_rdata_i,
    input logic [1:0] axi_master_rresp_i,
    input logic axi_master_rvalid_i,
    output logic axi_master_rready_o

);
    ADAM_SEQ seq_port ();
    assign seq_port.clk = clk_i;
    assign seq_port.rst = rst_i;

    AXI_LITE #(
        AXI_ADDR_WIDTH = 32,
        AXI_DATA_WIDTH = 32
    ) axi_slave [2] ();
    assign axi_slave[0].awaddr = axi_slave_0_awaddr_i;
    assign axi_slave[0].awprot = axi_slave_0_awprot_i;
    assign axi_slave[0].awvalid = axi_slave_0_awvalid_i;
    assign axi_slave[0].awready = axi_slave_0_awready_o;
    assign axi_slave[0].wdata = axi_slave_0_wdata_i;
    assign axi_slave[0].wstrb = axi_slave_0_wstrb_i;
    assign axi_slave[0].wvalid = axi_slave_0_wvalid_i;
    assign axi_slave[0].wready = axi_slave_0_wready_o;
    assign axi_slave[0].bresp = axi_slave_0_bresp_o;
    assign axi_slave[0].bvalid = axi_slave_0_bvalid_o;
    assign axi_slave[0].bready = axi_slave_0_bready_i;
    assign axi_slave[0].araddr = axi_slave_0_araddr_i;
    assign axi_slave[0].arprot = axi_slave_0_arprot_i;
    assign axi_slave[0].arvalid = axi_slave_0_arvalid_i;
    assign axi_slave[0].arready = axi_slave_0_arready_o;
    assign axi_slave[0].rdata = axi_slave_0_rdata_o;
    assign axi_slave[0].rresp = axi_slave_0_rresp_o;
    assign axi_slave[0].rvalid = axi_slave_0_rvalid_o;
    assign axi_slave[0].rready = axi_slave_0_rready_i;

    assign axi_slave[1].awaddr = axi_slave_1_awaddr_i;
    assign axi_slave[1].awprot = axi_slave_1_awprot_i;
    assign axi_slave[1].awvalid = axi_slave_1_awvalid_i;
    assign axi_slave[1].awready = axi_slave_1_awready_o;
    assign axi_slave[1].wdata = axi_slave_1_wdata_i;
    assign axi_slave[1].wstrb = axi_slave_1_wstrb_i;
    assign axi_slave[1].wvalid = axi_slave_1_wvalid_i;
    assign axi_slave[1].wready = axi_slave_1_wready_o;
    assign axi_slave[1].bresp = axi_slave_1_bresp_o;
    assign axi_slave[1].bvalid = axi_slave_1_bvalid_o;
    assign axi_slave[1].bready = axi_slave_1_bready_i;
    assign axi_slave[1].araddr = axi_slave_1_araddr_i;
    assign axi_slave[1].arprot = axi_slave_1_arprot_i;
    assign axi_slave[1].arvalid = axi_slave_1_arvalid_i;
    assign axi_slave[1].arready = axi_slave_1_arready_o;
    assign axi_slave[1].rdata = axi_slave_1_rdata_o;
    assign axi_slave[1].rresp = axi_slave_1_rresp_o;
    assign axi_slave[1].rvalid = axi_slave_1_rvalid_o;
    assign axi_slave[1].rready = axi_slave_1_rready_i;

    banzAI(
        .seq_port(),
        .axi_slave(axi_slave),
        .axi_master()
    );

endmodule