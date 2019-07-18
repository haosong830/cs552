module cla_16b(A, B, C_in, S, C_out, clk);

	input [15:0] A, B;
	input          C_in;
	input	clk;
	output [15:0] S;
	output         C_out;

	wire [15:0] p;
	wire [15:0] g;
	wire [3:0] C;
	wire [3:0] P;
	wire [3:0] G;
	wire [3:0] co;
	//wire [15:0] S_sync;
	//wire C_out_sync;
	
	//ff_16b f0(clk, 1'b0, S_sync, S);
	//dff f1(.clk(clk), .rst(1'b0), .d(C_out_sync), .q(C_out));

	assign g = A & B;
	assign p = A | B;
	assign P[0] = p[3] & p[2] & p[1] & p[0];
	assign P[1] = p[7] & p[6] & p[5] & p[4];
	assign P[2] = p[11] & p[10] & p[9] & p[8];
	assign P[3] = p[15] & p[14] & p[13] & p[12];
	assign G[0] = g[3] | 
				  p[3] & g[2] | 
				  p[3] & p[2] & g[1] | 
				  p[3] & p[2] & p[1] & g[0];
	assign G[1] = g[7] | 
				  p[7] & g[6] | 
				  p[7] & p[6] & g[5] | 
				  p[7] & p[6] & p[5] & g[4];
	assign G[2] = g[11] | 
				  p[11] & g[10] | 
				  p[11] & p[10] & g[9] | 
				  p[11] & p[10] & p[9] & g[8];
	assign G[3] = g[15] | 
				  p[15] & g[14] | 
				  p[15] & p[14] & g[13] | 
				  p[15] & p[14] & p[13] & g[12];
	assign C[0] = C_in;
	assign C[1] = G[0] | 
				  P[0] & C_in;
	assign C[2] = G[1] | 
				  G[0] & P[1] | 
				  P[1] & P[0] & C_in;
	assign C[3] = G[2] | 
				  G[1] & P[2] | 
				  G[0] & P[2] & P[1] | 
				  P[2] & P[1] & P[0] & C_in;
	assign C_out = G[3] | 
				   G[2] & P[3] | 
	 			   G[1] & P[3] & P[2] | 
	 			   G[0] & P[3] & P[2] & P[1] | 
				   P[3] & P[2] & P[1] & P[0] & C_in;
	
	cla_4b cla_4b_1 (.A(A[3:0]), .B(B[3:0]), .C_in(C[0]), .S(S[3:0]), .C_out(co[0]), .clk(clk));
	cla_4b cla_4b_2 (.A(A[7:4]), .B(B[7:4]), .C_in(C[1]), .S(S[7:4]), .C_out(co[1]), .clk(clk));
	cla_4b cla_4b_3 (.A(A[11:8]), .B(B[11:8]), .C_in(C[2]), .S(S[11:8]), .C_out(co[2]),.clk(clk));
	cla_4b cla_4b_4 (.A(A[15:12]), .B(B[15:12]), .C_in(C[3]), .S(S[15:12]), .C_out(co[3]), .clk(clk));

endmodule

