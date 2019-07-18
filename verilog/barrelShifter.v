/*
    CS/ECE 552 Spring '19
    Homework #4, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the Op() value that is passed in (2 bit number).  It uses these
    shifts to shift the value any number of bits between 0 and 15 bits.
 */
module barrelShifter (In, Cnt, Op, Out);

   // declare constant for size of inputs, outputs (N) and # bits to shift (C)
   parameter   N = 16;
   parameter   C = 4;
   parameter   O = 2;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   input [O-1:0]   Op;
   output reg [N-1:0]  Out;
   /* YOUR CODE HERE */
   always @(In, Cnt, Op) begin
     case(Op)
	2'b00: begin//rotate left case
		Out = In;
		Out = Cnt[3] ? {Out[7:0],  Out[15: 8]} : Out;
		Out = Cnt[2] ? {Out[11:0], Out[15:12]} : Out;
		Out = Cnt[1] ? {Out[13:0],Out[15:14]} : Out;
		Out  = Cnt[0] ? {Out[14:0],Out[15]} : Out;
	end/* when Cnt[i] is 1, then the left part is selected. With the increase of Cnt, the left part will perform
	shift left with corresponding amount and the MSB of the last operation of out will fill to the top bits of new Out. */

       
       2'b01: begin// shift left logical case 
       		Out = In;
		Out = Cnt[3] ? { Out[7:0], 8'b0} : Out;
		Out = Cnt[2] ? { Out[11:0], 4'b0} : Out;
	 	Out = Cnt[1] ? { Out[13:0], 2'b0} : Out;
		Out = Cnt[0] ? { Out[14:0], 1'b0} : Out;
	end
		// shift left by append lower bits to higher bits and fill lower bits with 0
       
       2'b10: begin  // rotate right case 
		Out = In;
       	Out = Cnt[3] ? {Out[7:0], Out[15:8]} : Out;
		Out = Cnt[2] ? {Out[3:0], Out[15:4]} : Out;
		Out = Cnt[1] ? {Out[1:0], Out[15:2]} : Out;
		Out = Cnt[0] ? {Out[0], Out[15:1]} : Out;
	end
				
				
       		
       2'b11:  begin// shift right logical case
       		Out = In;
		Out = Cnt[3] ? { 8'b0, Out[15:8]} : Out;
		Out = Cnt[2] ? { 4'b0, Out[15:4]} : Out;
	 	Out = Cnt[1] ? { 2'b0, Out[15:2]} : Out;
		Out = Cnt[0] ? { 1'b0, Out[15:1]} : Out; 
	end// just as right shift arithmetic but without sign extension
     endcase
   end
endmodule
