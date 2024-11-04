module complex_decoder_left #(parameter Narray = 2, N = 8)
(
        input logic CWL_left,
	input logic inference, read_1, read_8,
        input logic [Narray-1:0] adr_full_row, 
        output logic [2**Narray-1:0] CWL_in,
        output logic [2**Narray-1:0] selected_left
);

// Instructions
        /* verilator lint_off IMPLICIT */
	assign read = read_1 | read_8;

// Decoder
	assign selected_left = inference ? 4'b0 : (read ? 4'b1111 : 4'b1 << adr_full_row); 
	assign CWL_in = inference ? 4'b0 : (CWL_left ? selected_left : 4'b0);




endmodule