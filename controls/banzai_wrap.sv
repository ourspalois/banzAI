`include "adam/macros.svh"
module banzai_wrap #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave seq_port,
    AXI_LITE.Slave axi_slave[2], 
    AXI_LITE.Master axi_master
);

    logic clk_i, rst_i;
    assign clk_i = seq_port.clk;
    assign rst_i = seq_port.rst;

    logic [31:0] axi_slave_0_awaddr_i;
    logic [2:0] axi_slave_0_awprot_i;
    logic axi_slave_0_awvalid_i;
    logic axi_slave_0_awready_o;
    logic [31:0] axi_slave_0_wdata_i;
    logic [3:0] axi_slave_0_wstrb_i;
    logic axi_slave_0_wvalid_i;
    logic axi_slave_0_wready_o;
    logic axi_slave_0_bresp_o;
    logic axi_slave_0_bvalid_o;
    logic axi_slave_0_bready_i;
    logic [31:0] axi_slave_0_araddr_i;
    logic [2:0] axi_slave_0_arprot_i;
    logic axi_slave_0_arvalid_i;
    logic axi_slave_0_arready_o;
    logic [31:0] axi_slave_0_rdata_o;
    logic [1:0] axi_slave_0_rresp_o;
    logic axi_slave_0_rvalid_o;
    logic axi_slave_0_rready_i;
    assign axi_slave_0_awaddr_i = axi_slave[0].aw_addr;
    assign axi_slave_0_awprot_i = axi_slave[0].aw_prot;
    assign axi_slave_0_awvalid_i = axi_slave[0].aw_valid;
    assign axi_slave[0].aw_ready = axi_slave_0_awready_o;
    assign axi_slave_0_wdata_i = axi_slave[0].w_data;
    assign axi_slave_0_wstrb_i = axi_slave[0].w_strb;
    assign axi_slave_0_wvalid_i = axi_slave[0].w_valid;
    assign axi_slave[0].w_ready = axi_slave_0_wready_o;
    assign axi_slave[0].b_resp = axi_slave_0_bresp_o;
    assign axi_slave[0].b_valid = axi_slave_0_bvalid_o;
    assign axi_slave_0_bready_i = axi_slave[0].b_ready;
    assign axi_slave_0_araddr_i = axi_slave[0].ar_addr;
    assign axi_slave_0_arprot_i = axi_slave[0].ar_prot;
    assign axi_slave_0_arvalid_i = axi_slave[0].ar_valid;
    assign axi_slave[0].ar_ready = axi_slave_0_arready_o;
    assign axi_slave[0].r_data = axi_slave_0_rdata_o;
    assign axi_slave[0].r_resp = axi_slave_0_rresp_o;
    assign axi_slave[0].r_valid = axi_slave_0_rvalid_o;
    assign axi_slave_0_rready_i = axi_slave[0].r_ready;

    logic [31:0] axi_slave_1_awaddr_i;
    logic [2:0] axi_slave_1_awprot_i;
    logic axi_slave_1_awvalid_i;
    logic axi_slave_1_awready_o;
    logic [31:0] axi_slave_1_wdata_i;
    logic [3:0] axi_slave_1_wstrb_i;
    logic axi_slave_1_wvalid_i;
    logic axi_slave_1_wready_o;
    logic axi_slave_1_bresp_o;
    logic axi_slave_1_bvalid_o;
    logic axi_slave_1_bready_i;
    logic [31:0] axi_slave_1_araddr_i;
    logic [2:0] axi_slave_1_arprot_i;
    logic axi_slave_1_arvalid_i;
    logic axi_slave_1_arready_o;
    logic [31:0] axi_slave_1_rdata_o;
    logic [1:0] axi_slave_1_rresp_o;
    logic axi_slave_1_rvalid_o;
    logic axi_slave_1_rready_i;
    assign axi_slave_1_awaddr_i = axi_slave[1].aw_addr;
    assign axi_slave_1_awprot_i = axi_slave[1].aw_prot;
    assign axi_slave_1_awvalid_i = axi_slave[1].aw_valid;
    assign axi_slave[1].aw_ready = axi_slave_1_awready_o ;
    assign axi_slave_1_wdata_i = axi_slave[1].w_data;
    assign axi_slave_1_wstrb_i = axi_slave[1].w_strb;
    assign axi_slave_1_wvalid_i = axi_slave[1].w_valid;
    assign axi_slave[1].w_ready = axi_slave_1_wready_o;
    assign axi_slave[1].b_resp = axi_slave_1_bresp_o;
    assign axi_slave[1].b_valid = axi_slave_1_bvalid_o;
    assign axi_slave_1_bready_i = axi_slave[1].b_ready;
    assign axi_slave_1_araddr_i = axi_slave[1].ar_addr;
    assign axi_slave_1_arprot_i = axi_slave[1].ar_prot;
    assign axi_slave_1_arvalid_i = axi_slave[1].ar_valid;
    assign axi_slave[1].ar_ready = axi_slave_1_arready_o;
    assign axi_slave[1].r_data = axi_slave_1_rdata_o;
    assign axi_slave[1].r_resp = axi_slave_1_rresp_o;
    assign axi_slave[1].r_valid = axi_slave_1_rvalid_o;
    assign axi_slave_1_rready_i = axi_slave[1].r_ready;

    logic [31:0] axi_master_awaddr_o;
    logic [2:0] axi_master_awprot_o;
    logic axi_master_awvalid_o;
    logic axi_master_awready_i;
    logic [31:0] axi_master_wdata_o;
    logic [3:0] axi_master_wstrb_o;
    logic axi_master_wvalid_o;
    logic axi_master_wready_i;
    logic [31:0] axi_master_bresp_i;
    logic axi_master_bvalid_i;
    logic axi_master_bready_o;
    logic [31:0] axi_master_araddr_o;
    logic [2:0] axi_master_arprot_o;
    logic axi_master_arvalid_o;
    logic axi_master_arready_i;
    logic [31:0] axi_master_rdata_i;
    logic [1:0] axi_master_rresp_i;
    logic axi_master_rvalid_i;
    logic axi_master_rready_o;


    assign axi_master.aw_addr = axi_master_awaddr_o;
    assign axi_master.aw_prot = axi_master_awprot_o;
    assign axi_master.aw_valid = axi_master_awvalid_o;
    assign axi_master_awready_i = axi_master.aw_ready;
    assign axi_master.w_data = axi_master_wdata_o;
    assign axi_master.w_strb = axi_master_wstrb_o;
    assign axi_master.w_valid = axi_master_wvalid_o;
    assign axi_master_wready_i = axi_master.w_ready;
    assign axi_master_bresp_i = axi_master.b_resp;
    assign axi_master_bvalid_i = axi_master.b_valid;
    assign axi_master.b_ready = axi_master_bready_o;
    assign axi_master.ar_addr = axi_master_araddr_o;
    assign axi_master.ar_prot = axi_master_arprot_o;
    assign axi_master.ar_valid = axi_master_arvalid_o ;
    assign axi_master_arready_i = axi_master.ar_ready;
    assign axi_master_rdata_i = axi_master.r_data;
    assign axi_master_rresp_i = axi_master.r_resp;
    assign axi_master_rvalid_i = axi_master.r_valid;
    assign axi_master.r_ready = axi_master_rready_o ;



    banzai_unwrap banzai_u(
        .clk_i(clk_i),
        .rst_i(rst_i),

        .axi_slave_0_awaddr_i(axi_slave_0_awaddr_i),
        .axi_slave_0_awprot_i(axi_slave_0_awprot_i),
        .axi_slave_0_awvalid_i(axi_slave_0_awvalid_i),
        .axi_slave_0_awready_o(axi_slave_0_awready_o),
        .axi_slave_0_wdata_i(axi_slave_0_wdata_i),
        .axi_slave_0_wstrb_i(axi_slave_0_wstrb_i),
        .axi_slave_0_wvalid_i(axi_slave_0_wvalid_i),
        .axi_slave_0_wready_o(axi_slave_0_wready_o),
        .axi_slave_0_bresp_o(axi_slave_0_bresp_o),
        .axi_slave_0_bvalid_o(axi_slave_0_bvalid_o),
        .axi_slave_0_bready_i(axi_slave_0_bready_i),
        .axi_slave_0_araddr_i(axi_slave_0_araddr_i),
        .axi_slave_0_arprot_i(axi_slave_0_arprot_i),
        .axi_slave_0_arvalid_i(axi_slave_0_arvalid_i),
        .axi_slave_0_arready_o(axi_slave_0_arready_o),
        .axi_slave_0_rdata_o(axi_slave_0_rdata_o),
        .axi_slave_0_rresp_o(axi_slave_0_rresp_o),
        .axi_slave_0_rvalid_o(axi_slave_0_rvalid_o),
        .axi_slave_0_rready_i(axi_slave_0_rready_i),

        .axi_slave_1_awaddr_i(axi_slave_1_awaddr_i),
        .axi_slave_1_awprot_i(axi_slave_1_awprot_i),
        .axi_slave_1_awvalid_i(axi_slave_1_awvalid_i),
        .axi_slave_1_awready_o(axi_slave_1_awready_o),
        .axi_slave_1_wdata_i(axi_slave_1_wdata_i),
        .axi_slave_1_wstrb_i(axi_slave_1_wstrb_i),
        .axi_slave_1_wvalid_i(axi_slave_1_wvalid_i),
        .axi_slave_1_wready_o(axi_slave_1_wready_o),
        .axi_slave_1_bresp_o(axi_slave_1_bresp_o),
        .axi_slave_1_bvalid_o(axi_slave_1_bvalid_o),
        .axi_slave_1_bready_i(axi_slave_1_bready_i),
        .axi_slave_1_araddr_i(axi_slave_1_araddr_i),
        .axi_slave_1_arprot_i(axi_slave_1_arprot_i),
        .axi_slave_1_arvalid_i(axi_slave_1_arvalid_i),
        .axi_slave_1_arready_o(axi_slave_1_arready_o),
        .axi_slave_1_rdata_o(axi_slave_1_rdata_o),
        .axi_slave_1_rresp_o(axi_slave_1_rresp_o),
        .axi_slave_1_rvalid_o(axi_slave_1_rvalid_o),
        .axi_slave_1_rready_i(axi_slave_1_rready_i),

        .axi_master_awaddr_o(axi_master_awaddr_o),
        .axi_master_awprot_o(axi_master_awprot_o),
        .axi_master_awvalid_o(axi_master_awvalid_o),
        .axi_master_awready_i(axi_master_awready_i),
        .axi_master_wdata_o(axi_master_wdata_o),
        .axi_master_wstrb_o(axi_master_wstrb_o),
        .axi_master_wvalid_o(axi_master_wvalid_o),
        .axi_master_wready_i(axi_master_wready_i),
        .axi_master_bresp_i(axi_master_bresp_i),
        .axi_master_bvalid_i(axi_master_bvalid_i),
        .axi_master_bready_o(axi_master_bready_o),
        .axi_master_araddr_o(axi_master_araddr_o),
        .axi_master_arprot_o(axi_master_arprot_o),
        .axi_master_arvalid_o(axi_master_arvalid_o),
        .axi_master_arready_i(axi_master_arready_i),
        .axi_master_rdata_i(axi_master_rdata_i),
        .axi_master_rresp_i(axi_master_rresp_i),
        .axi_master_rvalid_i(axi_master_rvalid_i),
        .axi_master_rready_o(axi_master_rready_o)
    ) ;

    
endmodule