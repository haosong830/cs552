/*
	This module creates a 16-bit register.  It has 1 write port, 2 read
	ports, a write enable, a reset, and a clock input.  All register state changes occur on the rising edge of the
	clock.
 */
module oneReg (
           // Outputs
           readData, err,
           // Inputs
           clk, rst, writeData, writeEn
           );
   
   input        clk, rst;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] readData;
   output        err;

   wire [15:0] regBits;
   
   //When write enable, write some bits. Otherwise, write the readData to the registers.
   assign regBits = (writeEn == 1) ? writeData : readData;
   //Detect whether there is an unknown value
   assign err = 0;
   //Use 16 D-flipflop to save bits
   dff regBit[15:0](.q(readData), .d(regBits), .clk(clk), .rst(rst));
endmodule
