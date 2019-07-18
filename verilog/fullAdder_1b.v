/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out);
    input  A, B;
    input  C_in;
    output S;
    output C_out;

    // YOUR CODE HERE
	wire U1,U2,U3,U4,U5,U6,U7;
	nand2 NA1(A, B, U1);
	nand2 NA2(U1, A, U2);
 	nand2 NA3(U1, B, U3);
	nand2 NA4(U2, U3, U4);
	nand2 NA5(U4, C_in, U5);
	nand2 NA6(U5, U4, U6);
	nand2 NA7(U5, C_in, U7);
	nand2 NA8(U6, U7, S);
	nand2 NA9(U1, U5, C_out); 
endmodule
