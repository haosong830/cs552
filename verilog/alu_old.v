/*
    CS/ECE 552 Spring '19
    Homework #4, Problem 2

    A 16-bit ALU module.  It is designed to choose
    the correct operation to perform on 2 16-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the 16-bit result
    of the operation, as well as output a Zero bit and an Overflow
    (OFL) bit.
*/
module alu_old (A, B, Cin, Op, invA, invB, sign, Out, Zero, Ofl, clk);

   // declare constant for size of inputs, outputs (N),
   // and operations (O)
   parameter    N = 16;
   parameter    O = 3;
   
   input [N-1:0] A;
   input [N-1:0] B;
   input         Cin;
   input [O-1:0] Op;
   input         invA;
   input         invB;
   input         sign;
   input		clk;
   output  reg [N-1:0] Out;
   output   reg      Ofl;
   output    reg     Zero;
   wire Cout; // the intermediate to store carry out bit
   wire [15:0] out_shft; // intermediate to store the shift result
   wire [15:0] out_cla; // intermediate to store arithmetic result
   wire [15:0] nA; // store invert of A
   wire [15:0] nB; // store invert of B
   wire [15:0] Shifter_out_sync;
   wire [15:0] claOut_sync;
   /* YOUR CODE HERE */
   barrelShifter shifter(nA, nB[3:0], Op[1:0], out_shft);
   cla_16b cla(nA, nB, Cin, out_cla, Cout, clk);
   //ff_16b f0(clk,1'b0,out_shft,Shifter_out_sync);
  // ff_16b f1(clk,1'b0,out_cla,claOut_sync);
   assign nA = invA ? ~A : A;
   assign nB = invB ? ~B : B;
   always @(*) begin
	case(Op)
	//shift and rotate operations:
	  3'b000: begin//shift and rotate operations, simply call barrelShifter module 
		//$display("%h", out_shft);
		Out = out_shft;
		Ofl = 0;
	  end
	  3'b001: begin//shift and rotate operations, simply call barrelShifter module 
		//$display("%h", out_shft);
		Out = out_shft;
		Ofl = 0;
	  end
	  3'b010: begin//shift and rotate operations, simply call barrelShifter module 
		//$display("%h", out_shft);
		Out = out_shft;
		Ofl = 0;
	  end
	  3'b011: begin//shift and rotate operations, simply call barrelShifter module 
		//$display("%h", out_shft);
		Out =out_shft;
		Ofl = 0;
	  end
// arithmetic and logical operations
	  3'b100: begin // ADD case
		Out = out_cla;
		Ofl = ( ( sign & (nA[15] == nB[15]) & (nA[15] != Out[15]) ) | (~sign & Cout) );
		/*overflow detection: if numbers are signed, and the MSBs of each number are equal, and the MSB of one number
		is not equal to the MSB of Out, then Overflow occurs. Or if numbers are unsigned and Cout is 1, overflow occurs
		otherwise Ofl should be set to 0. */
	  end	  
	  3'b101: begin // SUB case
		Out = out_cla;
		Ofl = ( ( sign & (nA[15] == nB[15]) & (nA[15] != Out[15]) ) | (~sign & Cout) );
	  end	  
 	  3'b111: begin // bitwise NAND case
		Out = nA & ~nB;
		Ofl = 0;
          end
	  3'b110: begin // bitwise XOR case
		Out = nA ^ nB;
		Ofl = 0;
	  end
 	endcase
	Zero = ~|Out;
   end 
endmodule
