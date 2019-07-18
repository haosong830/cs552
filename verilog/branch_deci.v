module branch_deci(regRs, Op, Out);
	//Inputs
	input [15:0] regRs;
	input [1:0] Op;
	//Output
	output Out;

	wire notZero;
	assign notZero = |regRs;
	assign Out = (Op == 2'b00) ? notZero :				//BNEZ
				 (Op == 2'b01) ? ~notZero : 			//BEQZ
				 (Op == 2'b10) ? regRs[15] : 			//BLTZ
				 ~regRs[15];							//BGEZ
endmodule
