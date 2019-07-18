module	ff_16b(input clk, input rst, input [15:0] data_in, output [15:0] data_out);
	dff ff[15:0] (.q(data_out), .d(data_in), .rst(rst), .clk(clk));
endmodule
