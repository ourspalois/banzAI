
//****************************** Stochastic computing **********************
module bot_logic #(parameter M = 8)
(	input logic [M-1:0] DATA,
	input logic [M-1:0] rnd, 
	input logic [$clog2(M)-1:0] adr_c,
	input logic bit_prev, select, adr_0,
	input logic stoch_log,
	input logic [M-1:0] DATA_prev,
	input logic inference,
	output logic [M-1:0] DATA_next,
	output logic bit_next
);

	logic probaBit, bit_prev0;
	assign bit_prev0 = stoch_log ? 1'b0 : bit_prev;
	Gupta #(M) gupta(.rnd(rnd), .proba(DATA), .probabit(probaBit));

	logic selecting_out;
	selecting #(M) sel(.adr(adr_c), .proba(DATA), .select(select), .adr_0(adr_0), .probabit(probaBit), .selecting_out(selecting_out));

	assign bit_next = selecting_out & bit_prev0;

	logic [M-1:0] DATA_auth;
	assign DATA_auth = inference ? DATA : 8'b0;
	additions #(M) add(.proba1(DATA_auth), .proba2(DATA_prev), .proba_out(DATA_next)); 



endmodule