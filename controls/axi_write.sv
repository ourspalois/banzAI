module axi_write (
    ADAM_SEQ.Slave seq_port,
    AXI_LITE.Master axi_master, 

    // Maestro side (priority side)
    input logic [31:0] maestro_adress_i,
    input logic [31:0] maestro_data_i,
    input logic maestro_req_i,
    output logic maestro_valid_o,
    output logic maestro_ack_o,

    // FSM side (low priority)
    input logic [31:0] fsm_adress_i,
    input logic [31:0] fsm_data_i,
    input logic fsm_req_i,
    output logic fsm_valid_o, //TODO : management valid 
    output logic fsm_ack_o
);
    // structures : 
    // 1. input buffer and arbitter 
    // write and response management 

    logic req, ack, valid ;
    logic arbiter ;

    assign maestro_ack_o = ack && arbiter; 
    assign fsm_ack_o = ack && !(arbiter) ;

    assign req = maestro_req_i || fsm_req_i ;

    always_ff @( posedge seq_port.clk ) begin 
        if(seq_port.rst) begin
            valid <= 1'b0;
            axi_master.aw_valid <= 1'b0;
            axi_master.w_valid <= 1'b0;
            axi_master.w_strb <= 4'b1111;
            axi_master.aw_addr <= 32'h0;
            axi_master.b_ready <= 1'b0;
            axi_master.w_data <= 32'h0;
            ack <= 1'b0;
        end else begin
            if(req && (ack==0) && (axi_master.aw_valid == 0)) begin
                if(maestro_req_i) begin
                    arbiter <= 1'b1;
                    axi_master.aw_addr <= maestro_adress_i;
                    axi_master.w_data <= maestro_data_i;
                end else if(fsm_req_i) begin
                    arbiter <= 1'b0;
                    axi_master.aw_addr <= fsm_adress_i;
                    axi_master.w_data <= fsm_data_i;
                end
                axi_master.aw_valid <= 1'b1;
                axi_master.w_valid <= 1'b1;
                axi_master.w_strb <= 4'b1111;
                axi_master.b_ready <= 1'b1;
            end else if(axi_master.aw_ready && axi_master.w_ready && axi_master.aw_valid) begin
                axi_master.aw_valid <= 1'b0;
                axi_master.w_valid <= 1'b0;
                ack <= 1'b1;
            end else if(axi_master.b_valid) begin
                axi_master.b_ready <= 1'b0;
                ack <= 1'b0;
            end else begin
                ack <= 1'b0;
            end 
        end
    end 
endmodule