//Gupta module
module Gupta #(parameter M = 8) //???????????????????
(	input logic [M-1:0] rnd,
 	input logic [M-1:0] proba,
 	output logic probabit);
	// verilator lint_off UNOPTFLAT
	logic [M-2:0] Ni;
	// verilator lint_off UNOPTFLAT
	logic [M-2:0] Oi;

//Bloc 1

	assign Ni[0]=~rnd[M-1];
	assign Oi[0]=rnd[M-1]&proba[M-1];

//Bloc de base
	  generate
		genvar i;
		for (i=1; i<=M-2; i=i+1) begin
			assign Ni[i]=(~rnd[M-i-1])&Ni[i-1];
			assign Oi[i]=Oi[i-1]|(proba[M-i-1]&Ni[i-1]&rnd[M-i-1]);
		end
	  endgenerate

//Bloc final
	assign probabit=Oi[M-2]|(proba[0]&rnd[0]&Ni[M-2]);

endmodule