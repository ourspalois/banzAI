`include "macros.svh"

module testbench #(
    parameter CLK_PERIOD = 10, 
    `ADAM_CFG_PARAMS
)();

    logic clk, rst_n;
    AXI_LITE #(
        .AXI_DATA_WIDTH(32),
        .AXI_ADDR_WIDTH(32)
    ) axi_slave[2] ();
    virtual AXI_LITE #(
        .AXI_DATA_WIDTH(32),
        .AXI_ADDR_WIDTH(32)
    ) virtual_axi_slave[2] ;
    initial begin
        virtual_axi_slave[0] = axi_slave[0];
        virtual_axi_slave[1] = axi_slave[1];
    end

    AXI_LITE #(
        .AXI_DATA_WIDTH(32),
        .AXI_ADDR_WIDTH(32)
    ) axi_master ();

    ADAM_SEQ seq () ;

    PWR_CTRL #(
        .reg_num(16)
    ) dut(
        .seq_port(seq),
        .axi_port(axi_slave), 
        .axi_master(axi_master)
    );

    assign seq.clk = clk;
    assign seq.rst = ~rst_n;
    initial begin
        clk = 1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end   

    // reads the writes 
    initial begin
        forever begin
            @(posedge clk);
            axi_master.aw_ready = 1;
            axi_master.w_ready = 1;
            if(axi_master.aw_valid) begin
                $display("Write to address %h", axi_master.aw_addr);
                if(axi_master.aw_addr >= MMAP_SYSCFG.start && axi_master.aw_addr < MMAP_SYSCFG.end_) begin
                    $display("CHANGING POWER STATUS");
                    axi_master.b_valid = 1;
                end else begin
                    axi_master.b_valid = 0;
                end
                axi_master.b_valid = 1;
            end else begin
                axi_master.b_valid = 0;
            end
        end
    end

    // reads the reads
    initial begin
        forever begin
            @(posedge clk);
            axi_master.ar_ready = 1;
            if(axi_master.ar_valid) begin
                $display("Read from address %h", axi_master.ar_addr);
                axi_master.r_valid = 1;
                axi_master.r_data = 32'h12345678;
            end else begin
                axi_master.r_valid = 0;
            end
        end
    end

    task axi_read(input int port_index, input [31:0] address, output [31:0] data);
        virtual_axi_slave[port_index].ar_valid = 1;
        virtual_axi_slave[port_index].r_ready = 1;
        virtual_axi_slave[port_index].ar_addr = address;
        while (!virtual_axi_slave[port_index].ar_ready) begin
            #CLK_PERIOD;
        end
        virtual_axi_slave[port_index].ar_valid = 0;
        while (!virtual_axi_slave[port_index].r_valid) begin
            #CLK_PERIOD;
        end
        data = virtual_axi_slave[port_index].r_data;
        virtual_axi_slave[port_index].r_ready = 0;
        virtual_axi_slave[port_index].ar_addr = 0;
        #CLK_PERIOD ; 
    endtask

    task axi_write(input int port_index, input [31:0] address, input [31:0] data);
        virtual_axi_slave[port_index].b_ready = 1;
        virtual_axi_slave[port_index].aw_addr = address;
        virtual_axi_slave[port_index].w_data = data;
        virtual_axi_slave[port_index].aw_valid = 1;
        virtual_axi_slave[port_index].w_valid = 1;
        while (!(virtual_axi_slave[port_index].aw_ready && virtual_axi_slave[port_index].w_ready)) begin
            #CLK_PERIOD;
        end
        virtual_axi_slave[port_index].aw_valid = 0;
        virtual_axi_slave[port_index].w_valid = 0;
        while (!virtual_axi_slave[port_index].b_valid) begin
            #CLK_PERIOD;
        end
        virtual_axi_slave[port_index].b_ready = 0;
        #CLK_PERIOD ;
    endtask

    task reset();
        // test reset 
        rst_n = 0;
        #(30 * CLK_PERIOD) ;
        rst_n = 1;
        #(30 * CLK_PERIOD) ; 
    endtask 

    logic [31:0] data_in;
    logic [31:0] expected_data;
    logic [31:0] data_out;

    initial begin
        $display("Starting testbench");
        reset();
        $display("Reset complete");

        axi_write(0, 32'h28, 32'h1f4);

        // test register write
        data_in = 32'h12345678;
        axi_write(0, 0, data_in);

        
        #(1000 * CLK_PERIOD) ;
        //$finish;
    end

endmodule