//This alu contains the old alu unit which can do add, subtract, xor, nand and shift.
//The new instructions added are SEQ, SLT, SLE, SCO, BTR, LBI and SLBI
module alu (A, B, Op, Out, Zero, Ofl, clk, rst);
	//Inputs
	input [15:0] A;
	input [15:0] B;
	input [3:0] Op;
	input clk;
	input rst;
	//Outputs
	output [15:0] Out;
	output Zero;
	output Ofl;
	wire [15:0] old_out;
	reg [15:0] flag_out;	//output for SEQ, SLT, SLE, SCO, BTR, LBI and SLBI
	wire com_control;		//control whether sub A or not (set invA = 1 and Cin = 1)
	wire sub_control;		//control whether sub B or not (set invB = 1 and Cin = 1)
	wire invA, invB, sign, Cin;
	wire [2:0] aluOp;
	wire [15:0] flagOut_sync;
	wire [15:0] oldOut_sync;
	wire [15:0] Out_sync;
	wire Ofl_sync;
	wire Zero_sync;
	alu_old old(
				.A				(A),
				.B				(B),
				.Cin			(Cin),
				.Op				(aluOp),
				.invA			(invA),
				.invB			(invB),
				.sign			(sign),
				.Out			(old_out),
				.Zero			(Zero),
				.Ofl			(Ofl),
				.clk			(clk)
				);
	assign Out = Op[3] ? flag_out : old_out;
	assign invB = com_control ? 1'b1 : 1'b0;
	assign invA = sub_control ? 1'b1 : 1'b0;
	//set sign to be 0 if use it for overflow detection
	assign sign = (Op == 4'b1011) ? 1'b0 : 1'b1;
	assign Cin = com_control | sub_control;
	//sub_control = 1 if sub B is needed
	assign aluOp = Op[3] ? 3'b101 : Op[2:0];
	assign com_control = (Op == 4'b1000) ? 1'b1 :			//SEQ
						 (Op == 4'b1001) ? 1'b1 :			//SLT
						 (Op == 4'b1010) ? 1'b1 :			//SLE
						 1'b0;
	assign sub_control = (Op == 4'b0101) ? 1'b1 : 1'b0;		//SUBI and SUB
	always@(*)begin
		case(Op[2:0])
			3'b000 : flag_out = {15'h0000, Zero};					//SEQ
			//A[15] & ~B[15] is for the overflow situation (positive minus negative)
			3'b001 : flag_out = {15'h0000, old_out[15] & ~Ofl | A[15] & ~B[15]};		//SLT
			3'b010 : flag_out = {15'h0000, old_out[15] & ~Ofl | A[15] & ~B[15] | Zero};	//SLE
			3'b011 : flag_out = {15'h0000, Ofl};					//SCO
			3'b100 : flag_out = {A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7],
								 A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]};	//BTR
			3'b101 : flag_out = {{8{B[7]}}, B[7:0]};				//LBI
			3'b110 : flag_out = {A[7:0], B[7:0]};				//SLBI
			default : flag_out = 0;								//erro
		endcase
	end
	//ff_16b f0(clk, 1'b0, flag_out, flagOut_sync); // increase clock slack
	//ff_16b f1(clk, 1'b0,old_out,oldOut_sync);
	//dff f2(.clk(clk), .rst(rst), .d(Ofl_sync), .q(Ofl));
	//dff f3(.clk(clk), .rst(rst), .d(Zero_sync), .q(Zero));
	//ff_16b ff(clk, 1'b0, Out_sync, Out);
endmodule

