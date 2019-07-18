module cla_4b(A, B, C_in, S, C_out, clk);

	input [3:0] A, B;
	input          C_in;
	input	clk;
	output [3:0] S;
	output         C_out;

	wire [3:0] c;
	wire [3:0] p;
	wire [3:0] g;
	wire [3:0] adder_c_out;
	//wire [3:0] S_sync;
	//wire  Cout_sync;

	assign g = A & B;
	assign p = A | B;
	assign c[0] = C_in;
	assign c[1] = g[0] | 
				  p[0] & c[0];
	assign c[2] = g[1] | 
				  g[0] & p[1] | 
				  p[1] & p[0] & c[0];
	assign c[3] = g[2] | 
				  g[1] & p[2] | 
				  g[0] & p[2] & p[1] | 
				  p[2] & p[1] & p[0] & c[0];
	assign Cout = g[3] | 
				   g[2] & p[3] | 
	 			   g[1] & p[3] & p[2] | 
	 			   g[0] & p[3] & p[2] & p[1] | 
				   p[3] & p[2] & p[1] & p[0] & c[0];
	
	fullAdder_1b adder [3:0] (.A(A), .B(B), .C_in(c), .S(S), .C_out(adder_c_out));
	//dff ff[3:0](.clk(clk),.rst(1'b0),.d(S_sync),.q(S));
	//dff f2(.clk(clk),.rst(1'b0),.q(C_out),.d(Cout_sync));
endmodule

