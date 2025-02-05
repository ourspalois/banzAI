`include "adam/macros.svh"

module banzai_unwrap #(
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
        .AXI_ADDR_WIDTH(32),
        .AXI_DATA_WIDTH(32)
    ) axi_slave[2] () ;
    assign axi_slave[0].aw_addr = axi_slave_0_awaddr_i;
    assign axi_slave[0].aw_prot = axi_slave_0_awprot_i;
    assign axi_slave[0].aw_valid = axi_slave_0_awvalid_i;
    assign axi_slave_0_awready_o = axi_slave[0].aw_ready;
    assign axi_slave[0].w_data = axi_slave_0_wdata_i;
    assign axi_slave[0].w_strb = axi_slave_0_wstrb_i;
    assign axi_slave[0].w_valid = axi_slave_0_wvalid_i;
    assign axi_slave_0_wready_o = axi_slave[0].w_ready;
    assign axi_slave_0_bresp_o = axi_slave[0].b_resp;
    assign axi_slave_0_bvalid_o = axi_slave[0].b_valid;
    assign axi_slave[0].b_ready = axi_slave_0_bready_i;
    assign axi_slave[0].ar_addr = axi_slave_0_araddr_i;
    assign axi_slave[0].ar_prot = axi_slave_0_arprot_i;
    assign axi_slave[0].ar_valid = axi_slave_0_arvalid_i;
    assign axi_slave_0_arready_o = axi_slave[0].ar_ready;
    assign axi_slave_0_rdata_o = axi_slave[0].r_data;
    assign axi_slave_0_rresp_o = axi_slave[0].r_resp;
    assign axi_slave_0_rvalid_o = axi_slave[0].r_valid;
    assign axi_slave[0].r_ready = axi_slave_0_rready_i;

    assign axi_slave[1].aw_addr = axi_slave_1_awaddr_i;
    assign axi_slave[1].aw_prot = axi_slave_1_awprot_i;
    assign axi_slave[1].aw_valid = axi_slave_1_awvalid_i;
    assign axi_slave_1_awready_o = axi_slave[1].aw_ready;
    assign axi_slave[1].w_data = axi_slave_1_wdata_i;
    assign axi_slave[1].w_strb = axi_slave_1_wstrb_i;
    assign axi_slave[1].w_valid = axi_slave_1_wvalid_i;
    assign axi_slave_1_wready_o = axi_slave[1].w_ready;
    assign axi_slave_1_bresp_o = axi_slave[1].b_resp;
    assign axi_slave_1_bvalid_o = axi_slave[1].b_valid;
    assign axi_slave[1].b_ready = axi_slave_1_bready_i;
    assign axi_slave[1].ar_addr = axi_slave_1_araddr_i;
    assign axi_slave[1].ar_prot = axi_slave_1_arprot_i;
    assign axi_slave[1].ar_valid = axi_slave_1_arvalid_i;
    assign axi_slave_1_arready_o = axi_slave[1].ar_ready;
    assign axi_slave_1_rdata_o = axi_slave[1].r_data;
    assign axi_slave_1_rresp_o = axi_slave[1].r_resp;
    assign axi_slave_1_rvalid_o = axi_slave[1].r_valid;
    assign axi_slave[1].r_ready = axi_slave_1_rready_i;

    AXI_LITE #(
        .AXI_ADDR_WIDTH(32),
        .AXI_DATA_WIDTH(32)
    ) axi_master ();
    assign axi_master_awaddr_o = axi_master.aw_addr;
    assign axi_master_awprot_o = axi_master.aw_prot;
    assign axi_master_awvalid_o = axi_master.aw_valid;
    assign axi_master.aw_ready = axi_master_awready_i;
    assign axi_master_wdata_o = axi_master.w_data;
    assign axi_master_wstrb_o = axi_master.w_strb;
    assign axi_master_wvalid_o = axi_master.w_valid ;
    assign axi_master.w_ready = axi_master_wready_i;
    assign axi_master.b_resp = axi_master_bresp_i;
    assign axi_master.b_valid = axi_master_bvalid_i;
    assign axi_master_bready_o = axi_master.b_ready;
    assign axi_master_araddr_o = axi_master.ar_addr;
    assign axi_master_arprot_o = axi_master.ar_prot;
    assign axi_master_arvalid_o = axi_master.ar_valid;
    assign axi_master.ar_ready = axi_master_arready_i;
    assign axi_master.r_data = axi_master_rdata_i;
    assign axi_master.r_resp = axi_master_rresp_i;
    assign axi_master.r_valid = axi_master_rvalid_i;
    assign axi_master_rready_o = axi_master.r_ready;

    banzAI banzai(
        .seq_port(seq_port),
        .axi_slave(axi_slave),
        .axi_master(axi_master)
    );

endmodule