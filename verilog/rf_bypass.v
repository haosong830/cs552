/*
   CS/ECE 552, Spring '19
   Homework #5, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module rf_bypass (
                  // Outputs
                  readData1, readData2, err,
                  // Inputs
                  clk, rst, readReg1Sel, readReg2Sel, writeRegSel, writeData, writeEn
                  );
   input        clk, rst;
   input [2:0]  readReg1Sel;
   input [2:0]  readReg2Sel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] readData1;
   output [15:0] readData2;
   output        err;
   
   wire [15:0] read1;//the wire connects from readData to writeData
   wire [15:0] read2;
   /* YOUR CODE HERE */
   rf regFile(.clk(clk), .rst(rst), .readReg1Sel(readReg1Sel), .readReg2Sel(readReg2Sel), .writeRegSel(writeRegSel),
	      .writeData(writeData), .writeEn(writeEn), .readData1(read1), .readData2(read2), .err(err));
   /*logic: if write is enabled, we should be in the WB stage. Then check which register each port is reading from, and check whether they are
	equal to the write select(using XNOR gates), then assign readData ports to either writeData or read wires.*/
   assign readData1 = (writeEn & (writeRegSel == readReg1Sel))  ? writeData : 
   read1;
   assign readData2 = (writeEn & (writeRegSel == readReg2Sel))  ? writeData : 
   read2;
endmodule
