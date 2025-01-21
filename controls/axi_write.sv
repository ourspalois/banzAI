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

    logic [31:0] address, data ; 
    logic req, ack, ready, valid ;
    logic arbiter ;

    assign maestro_ack_o = ack && arbiter; 
    assign fsm_ack_o = ack && !(arbiter) ;

    always_ff @(posedge seq_port.clk) begin
        if(seq_port.rst) begin
            maestro_valid_o <= 1'b0;
            fsm_valid_o <= 1'b0;
        end else begin
            if(maestro_req_i) begin
                address <= maestro_adress_i;
                data <= maestro_data_i;
                req <= 1'b1;
                arbiter <= 1'b1 ; 
            end else if(fsm_req_i) begin
                address <= fsm_adress_i;
                data <= fsm_data_i;
                req <= 1'b1;
                arbiter <= 1'b0 ; 
            end else begin
                req <= 1'b0;
                arbiter <= 1'b0 ; 
            end        
        end
    end


    always_ff @( posedge seq_port.clk ) begin 
        if(seq_port.rst) begin
            ready <= 1'b0;
            valid <= 1'b0;
        end else begin
            if(req && axi_master.aw_ready && axi_master.w_ready && ack==0) begin
                axi_master.aw_addr <= address;
                axi_master.w_data <= data;
                axi_master.aw_valid <= 1'b1;
                axi_master.b_ready <= 1'b1;
                ack <= 1'b1;
            end else if(axi_master.b_valid) begin
                axi_master.b_ready <= 1'b0; 
                axi_master.aw_valid <= 1'b0;
                axi_master.w_valid <= 1'b0;
                ack <= 1'b0;
            end else begin
                axi_master.aw_valid <= 1'b0;
                axi_master.w_valid <= 1'b0;
                ack <= 1'b0;
            end 
        end
    end 
endmodule