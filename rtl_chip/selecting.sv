module selecting #(parameter M = 8)
(	input logic [$clog2(M)-1:0] adr,
	input logic [M-1:0] proba,
	input logic select,
	input logic adr_0,
	input logic probabit,
	output logic selecting_out );

	assign selecting_out = select ? ( adr_0 ? proba[adr] : 1'b1 ) : probabit ;


endmodule