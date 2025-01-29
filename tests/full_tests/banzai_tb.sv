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

    banzAI #(
    ) dut(
        .seq_port(seq),
        .axi_slave(axi_slave), 
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
                if(axi_master.aw_addr >= MMAP_SYSCFG.start && axi_master.aw_addr < MMAP_SYSCFG.end_) begin
                    $display("CHANGING POWER STATE of component %b, with state %b", (axi_master.aw_addr - MMAP_SYSCFG.start )>>2, axi_master.w_data ); 
                end else if(axi_master.aw_addr >= MMAP_ACCEL.start && axi_master.aw_addr < MMAP_ACCEL.end_) begin
                    $display("writing to accelerator, at adress : %h", axi_master.aw_addr);
                    axi_write(1, axi_master.aw_addr ^ MMAP_ACCEL.start, axi_master.w_data);
                end else begin
                    $display("Write to address %h", axi_master.aw_addr);
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

        // first we program the chip 
        axi_write(1, 32'h0   <<2, 32'hf);
        axi_write(1, 32'h80  <<2, 32'hf);
        axi_write(1, 32'h100 <<2, 32'hf);
        axi_write(1, 32'h180 <<2, 32'hf);
        axi_write(1, 32'h2004, 32'h1) ; // RESET/SET MODE
        axi_write(1, 32'h0   <<2, 32'hf);
        axi_write(1, 32'h80  <<2, 32'hf);
        axi_write(1, 32'h100 <<2, 32'hf);
        axi_write(1, 32'h180 <<2, 32'hf);

        // write obs 
        axi_write(1, 32'h200C, 32'h0);
        axi_write(1, 32'h2010, 32'h0);
        axi_write(1, 32'h2014, 32'h0);
        axi_write(1, 32'h2018, 32'h0);

        // log mode 
        axi_write(1, 32'h201C, 32'h1) ; // LOG MODE

        // read result
        axi_read(1, 32'h2000, data_out);
        $display("inference result : %h", data_out);

        // write alarm levels 
        axi_write(0, 32'h3c,  32'hff_ff_ff_10) ;

        // write idle lenght 
        axi_write(0, 32'h28,  32'h1f4) ; 

        // launc pwr manager
        data_in = 32'h12345678;
        axi_write(0, 0, data_in);
        
        #(1000 * CLK_PERIOD) ;
        //$finish;
    end

endmodule