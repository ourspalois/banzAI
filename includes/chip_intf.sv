interface chip_ports;
    logic clk, CBL, CBLEN, CWL, inference, load_seed, read_1, read_8, load_mem, read_out, stoch_log ; 
    logic [7:0] addr_full_col, addr_full_row, seeds ; 
    logic [3:0] bit_out ; 

    modport Master (
        output clk, CBL, CBLEN, CWL, inference, load_seed, read_1, read_8, load_mem, read_out, stoch_log, 
        output addr_full_col, addr_full_row, seeds, 
        input bit_out
    );

    modport Slave (
        input clk, CBL, CBLEN, CWL, inference, load_seed, read_1, read_8, load_mem, read_out, stoch_log,
        input addr_full_col, addr_full_row, seeds, 
        output bit_out
    );

    
endinterface //interfacename