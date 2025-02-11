interface chip_ports;
    logic clk, CBL, CBLEN, CWL, inference, load_seed, read_1, read_8, load_mem, read_out ; 
    logic [7:0] addr_full_col, addr_full_row, seeds ; 
    logic [3:0] bit_out ; 

    modport Master (
        output clk, CBL, CBLEN, CWL, inference, load_seed, read_1, read_8, load_mem, read_out, 
        output [7:0] addr_full_col, addr_full_row, seeds, 
        input [3:0] bit_out
    );

    modport Slave (
        input clk, CBL, CBLEN, CWL, inference, load_seed, read_1, read_8, load_mem, read_out, 
        input [7:0] addr_full_col, addr_full_row, seeds, 
        output [3:0] bit_out
    );

    
endinterface //interfacename