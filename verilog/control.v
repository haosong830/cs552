/*
   CS/ECE 552, Spring '19
   Homework #6, Problem #1
  
   This module determines all of the control logic for the processor.
*/
module control (/*AUTOARG*/
                // Outputs
                err, 
                RegDst,
                SESel,
                RegWrite,
                DMemWrite,
                DMemRead,
                ALUSrc2,
                PCSrc,				//only use PCSrc for branch instr
                PCImm,
                MemToReg,
                DMemDump,
                Jump,
				aluOp,
                // Inputs
                OpCode,
                Funct,
				rst
                );

   // inputs
   input [4:0]  OpCode;
   input [1:0]  Funct;
   input rst;
   
   // outputs
   output    reg   err;
   output    reg   RegWrite, DMemWrite, DMemRead, PCSrc, 
                PCImm, MemToReg, DMemDump, Jump;
	//ALUScr = 0 -> select regRt
	//ALUScr = 2'b01 -> select 0
	//ALUScr = 2'b10 -> select 5 bits extend
	//ALUScr = 2'b11 -> select 8 bits extend
   output	reg [1:0] ALUSrc2;		
   output reg [1:0] RegDst;
   output reg [2:0] SESel;
   output reg [3:0] aluOp;

   /* YOUR CODE HERE */
   always @(*) begin
		case(OpCode)
			5'b01000 : aluOp = 4'b0101;						//SUBI
			5'b01001 : aluOp = 4'b0100;						//ADDI
			5'b01010 : aluOp = 4'b0111;						//ANDNI
			5'b01011 : aluOp = 4'b0110;						//XORI
			5'b10100 : aluOp = 4'b0000;						//ROLI
			5'b10101 : aluOp = 4'b0001;						//SLLI
			5'b10110 : aluOp = 4'b0010;						//RORI
			5'b10111 : aluOp = 4'b0011;						//SRLI
			5'b10000 : aluOp = 4'b0100;						//ST
			5'b10001 : aluOp = 4'b0100;						//LD
			5'b10011 : aluOp = 4'b0100;						//STU
			5'b11001 : aluOp = 4'b1100;						//BTR
			5'b11011 : aluOp = 4'b0100 | Funct;				//ADD, SUB, ANDN, XOR
			5'b11010 : aluOp = 4'b0000 | Funct;				//ROL, SLL, ROR, SRL
			5'b11100 : aluOp = 4'b1000;						//SEQ
			5'b11101 : aluOp = 4'b1001;						//SLT
			5'b11110 : aluOp = 4'b1010;						//SLE
			5'b11111 : aluOp = 4'b1011;						//SCO
			5'b01100 : aluOp = 4'b1000;						//BNEZ
			5'b01101 : aluOp = 4'b1001;						//BEQZ
			5'b01110 : aluOp = 4'b1010;						//BLTZ
			5'b01111 : aluOp = 4'b1011;						//BGEZ
			5'b11000 : aluOp = 4'b1101;						//LBI
			5'b10010 : aluOp = 4'b1110;						//SLBI
			5'b00100 : aluOp = 4'b0100;						//J
			5'b00101 : aluOp = 4'b0100;						//JR
			5'b00110 : aluOp = 4'b0100;						//JAL
			5'b00111 : aluOp = 4'b0100;						//JALR
			default : aluOp = 4'b0000;
		endcase
   end
	always @(*) begin
		casex(OpCode)
			5'b0100x: begin //SUBI,ADDI
				RegDst = 2'b01;//select instruction bits 7:5
				SESel = 3'b010;//sign extend the lower 5 bits of the instruction (bits [4:0]) to make it a 16-bit value.
				RegWrite = 1;//this  bit is  1 if the  instruction writes to a register (e.g., ADDI) and  0 otherwise  (e.g., HALT).
				DMemWrite = 0;//this bit is 1 if the instruction writes to data memory (e.g., ST) and 0 otherwise (e.g., HALT).
				DMemRead = 0;
				ALUSrc2 = 2'b10;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;	
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b0101x: begin //ANDNI, XORI
				RegDst = 2'b01;//select instruction bits 7:5
				SESel = 3'b000; //zero extend the lower 5 bits of the instruction (bits [4:0])to make it a 16-bit value.
				RegWrite = 1;
				DMemWrite = 0;
				DMemRead = 0;
				ALUSrc2 = 2'b10;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b101xx: begin //ROLI, SLLI, RORI, SRLI
				RegDst = 2'b01;//select instruction bits 7:5
				SESel = 3'b000; 
				RegWrite = 1;
				DMemWrite = 0;
				DMemRead = 0;
				ALUSrc2 = 2'b10;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b10000: begin //ST(store)
				RegDst = 2'b01;//select instruction bits 7:5
				SESel = 3'b010; 
				RegWrite = 0;
				DMemWrite = 1;
				DMemRead = 0;
				ALUSrc2 = 2'b10;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b10001: begin//LD(load)
				RegDst = 2'b01;//select instruction bits 7:5
				SESel = 3'b010; 
				RegWrite = 1;
				DMemWrite = 0;
				DMemRead = 1;
				ALUSrc2 = 2'b10;
				PCSrc = 0;
				MemToReg = 1;
				DMemDump = 0;
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b10011: begin//STU
				RegDst = 2'b10;//select instruction bits 10:8
				SESel = 3'b010; 
				RegWrite = 1;
				DMemWrite = 1;
				DMemRead = 0;
				ALUSrc2 = 2'b10;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b11000: begin//LBI
				RegDst = 2'b10;
				SESel = 3'b100;
				RegWrite = 1;//this  bit is  1 if the  instruction writes to a register (e.g., ADDI) and  0 otherwise  (e.g., HALT).
				DMemWrite = 0;//this bit is 1 if the instruction writes to data memory (e.g., ST) and 0 otherwise (e.g., HALT).
				DMemRead = 0;
				ALUSrc2 = 2'b11;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;	
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b11xxx: begin//BTR,ADD,SUB,XOR,ANDN,ROL,SLL,ROR,SRL,SEQ,SLT,SLE,SCO
				RegDst = 2'b00;
				SESel = 3'b000;
				RegWrite = 1;//this  bit is  1 if the  instruction writes to a register (e.g., ADDI) and  0 otherwise  (e.g., HALT).
				DMemWrite = 0;//this bit is 1 if the instruction writes to data memory (e.g., ST) and 0 otherwise (e.g., HALT).
				DMemRead = 0;
				ALUSrc2 = 0;
				PCSrc = 0;
				MemToReg = 0;
				DMemDump = 0;	
				PCImm = 0;
				Jump = 0;
				err = 0;
			end 
			5'b011xx: begin//BNEZ,BEQZ,BLTZ,BGEZ
				RegDst = 2'b00;
				SESel = 3'b100;
				RegWrite = 0;//this  bit is  1 if the  instruction writes to a register (e.g., ADDI) and  0 otherwise  (e.g., HALT).
				DMemWrite = 0;//this bit is 1 if the instruction writes to data memory (e.g., ST) and 0 otherwise (e.g., HALT).
				DMemRead = 0;
				ALUSrc2 = 2'b01;
				PCSrc = 1;
				MemToReg = 0;
				DMemDump = 0;	
				PCImm = 0;
				Jump = 0;
				err = 0;
			end
			5'b00001:begin//NOP
   				RegDst = 2'b00;
   				SESel = 3'b000;
   				RegWrite = 0;
   				DMemWrite = 0;
   				DMemRead = 1'b0;
   				ALUSrc2 = 0;
   				PCSrc = 0;
   				MemToReg = 1'b0;
   				DMemDump = 0; 
   				PCImm = 0;
   				Jump = 0;
   				err = 0;
			end
			5'b00111:begin//JALR
   				RegDst = 2'b11;
   				SESel = 3'b100;
   				RegWrite = 1;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 2'b11;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 0; 
   				PCImm = 0;
   				Jump = 1;
   				err = 0;
			end
			5'b00110:begin//JAL
   				RegDst = 2'b11;
   				SESel = 3'b110;
   				RegWrite = 1;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 0;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 0; 
   				PCImm = 1;
   				Jump = 0;
   				err = 0;
			end
			5'b00101:begin//JR
   				RegDst = 2'b00;
   				SESel = 3'b100;
   				RegWrite = 0;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 2'b11;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 0; 
   				PCImm = 0;
   				Jump = 1;
   				err = 0;
			end
			5'b00100:begin//J
   				RegDst = 2'b00;
   				SESel = 3'b110;
   				RegWrite = 0;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 0;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 0; 
   				PCImm = 1;
   				Jump = 0;
   				err = 0;
				end
			5'b10010:begin//SLBI
   				RegDst = 2'b10;
   				SESel = 3'b001;
   				RegWrite = 1;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 2'b11;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 0; 
   				PCImm = 0;
   				Jump = 0;
   				err = 0;
			end
			5'b00000:begin//HALT
   				RegDst = 2'b00;
   				SESel = 3'b000;
   				RegWrite = 0;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 0;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 1 & ~rst;
   				PCImm = 0;
   				Jump = 0;
   				err = 0;
			end
			default: begin
   				RegWrite = 0;
   				DMemWrite = 0;
   				DMemRead = 0;
   				ALUSrc2 = 0;
   				PCSrc = 0;
   				MemToReg = 0;
   				DMemDump = 0; 
   				PCImm = 0;
   				Jump = 0;
   				err = 1;
			end
		endcase
	end
			
	 
endmodule
