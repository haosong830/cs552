
/*
   CS/ECE 552, Spring '19
   Homework #5, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module rf (
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

   /* YOUR CODE HERE */
   wire [15:0] regData[7:0];
   wire [7:0] writeRegEn;
   //Detect whether there is an unknown value
   assign err = 0;
   //Select which register you are going to read
   assign readData1 = regData[readReg1Sel];
   assign readData2 = regData[readReg2Sel];
   //Select which register you are going to write
   assign writeRegEn = (writeEn == 1) ? 
					   						(writeRegSel == 0) ? 8'b00000001 :
					   						(writeRegSel == 1) ? 8'b00000010 :
					   						(writeRegSel == 2) ? 8'b00000100 :
					   						(writeRegSel == 3) ? 8'b00001000 :
					   						(writeRegSel == 4) ? 8'b00010000 :
					   						(writeRegSel == 5) ? 8'b00100000 :
					   						(writeRegSel == 6) ? 8'b01000000 :
					   						(writeRegSel == 7) ? 8'b10000000 :
											8'b00000000
										  : 8'b00000000;
   //Connect 8 registers to the readData and writeData
   oneReg reg0(.readData(regData[0]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[0])
                   );
   oneReg reg1(.readData(regData[1]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[1])
                   );
   oneReg reg2(.readData(regData[2]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[2])
                   );
   oneReg reg3(.readData(regData[3]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[3])
                   );
   oneReg reg4(.readData(regData[4]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[4])
                   );
   oneReg reg5(.readData(regData[5]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[5])
                   );
   oneReg reg6(.readData(regData[6]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[6])
                   );
   oneReg reg7(.readData(regData[7]), .err(err), 
                   .clk(clk), .rst(rst), .writeData(writeData), .writeEn(writeRegEn[7])
                   );
endmodule
