module Decode(//Inputs
			  input rst, clk,
			  input [15:0] IFID_PC,
			  input [15:0] IFID_instr,
			  //hazard detection signals
			  input [2:0] IDEX_writeRegSel,
			  input [2:0] EXMEM_writeRegSel,
			  input [2:0] MEMWB_writeRegSel,
			  input [15:0] MEMWB_writeData,
			  input MEMWB_RegWrite,
			  input MEMWB_MEMtoMEM_forwarding_RegWrite,
			  input EXMEM_DMemRead,
			  input EXMEM_RegWrite,
			  input IDEX_RegWrite,
			  input IDEX_DMemRead,
			  input [15:0] EXMEM_exOut,
			  input [15:0] PC_add_2,
			  //Outputs
			  output RegWrite, DMemWrite, DMemRead, PCSrc,
			  			PCImm, MemToReg, DMemDump, Jump,		//control signals
			  output [2:0] writeRegSel,
			  output [3:0] aluOp,
			  output hazardStall,
			  output notImm, jalControl,
			  output [15:0] aluReg2,
			  output branchDeci,
			  output [15:0] regRs,
			  output [15:0] regRt,
			  output [15:0] jr_PC,
			  output flush,
			  output rfErr, conErr		//error signals
			 );

	wire usingRs, extend_sign_or_zero;
	wire j_C_out, b_C_out, jr_C_out;
	wire [15:0] jump_addr;
	wire [15:0] branch_addr;
	wire [15:0] jump_reg_addr;
	wire [2:0] SESel;
	wire [1:0] RegDst;
	wire [15:0] extend_5;
	wire [15:0] extend_8;
	wire [15:0] extend_11;
	wire [15:0] branch_forwarding_reg;
	wire branch_EXtoD, branch_MEMtoD;
	wire [15:0] b_PC;
	wire [1:0] ALUSrc2;
	wire [15:0] j_PC;
	//dicide it's zero extend or sign extend
	assign extend_sign_or_zero = SESel[2] | SESel[1]; 
	//sign extend for 5 bits Imm
	assign extend_5 = {{11{extend_sign_or_zero & IFID_instr[4]}}, 
					   IFID_instr[4:0]};
	//sign extend for 8 bits Imm
	assign extend_8 = {{8{extend_sign_or_zero & IFID_instr[7]}}, 
					   IFID_instr[7:0]};
	//sign extend for 11 bits Imm
	assign extend_11 = {{5{extend_sign_or_zero & IFID_instr[10]}},
					    IFID_instr[10:0]};
	//Jump address
	cla_16b jump_pc(
				      .A				(extend_11),
				      .B				(IFID_PC),
				      .C_in				(1'b0),
				      .S				(jump_addr),
				 	  .C_out			(j_C_out));
	//Branch address
	cla_16b branch_pc(
					  .A				(extend_8),
				      .B				(IFID_PC),
				      .C_in				(1'b0),
				      .S				(branch_addr),
				 	  .C_out			(b_C_out));
	//Jump register address
	cla_16b jump_reg_pc(
						.A				(branch_forwarding_reg),
						.B				(extend_8),
						.C_in			(1'b0),
						.S				(jump_reg_addr),
						.C_out			(jr_C_out));
	//branch decision
	branch_deci b_deci(
					   .regRs			(branch_forwarding_reg),
					   .Op				(aluOp[1:0]),
					   .Out				(branchDeci));
	assign branch_forwarding_reg = branch_EXtoD ? EXMEM_exOut : 
								   branch_MEMtoD ? MEMWB_writeData :
								   regRs;
	//branch or jr forwarding decision
	branch_forwarding bf(
						 .EXMEM_RdSel	(EXMEM_writeRegSel),
						 .MEMWB_RdSel	(MEMWB_writeRegSel),
						 .IFID_RsSel	(IFID_instr[10:8]),
						 .EXMEM_RegWrite(EXMEM_RegWrite),
						 .MEMWB_RegWrite(MEMWB_MEMtoMEM_forwarding_RegWrite),
						 .EXtoD_Rs		(branch_EXtoD),
						 .MEMtoD_Rs		(branch_MEMtoD));
	//control whether flush or not (branch or jump instruction)
	assign flush = (PCSrc & branchDeci) | Jump | PCImm;
	//choose branch or (PC + 2)
	assign b_PC = PCSrc & branchDeci ? branch_addr : PC_add_2;
	//choose jumping address or (PC + 2)
	assign j_PC = PCImm ? jump_addr : b_PC;
	//choose jumping to register or (PC + 2)
	assign jr_PC = Jump ? jump_reg_addr : j_PC;
	//control unit
	control con(
				//Outputs
				.err					(conErr),
				.RegDst					(RegDst),
				.SESel					(SESel),
				.RegWrite				(RegWrite),
				.DMemWrite				(DMemWrite),
				.DMemRead				(DMemRead),
				.ALUSrc2				(ALUSrc2),
				.PCSrc					(PCSrc),
				.PCImm					(PCImm),
				.MemToReg				(MemToReg),
				.DMemDump				(DMemDump),
				.Jump					(Jump),
				.aluOp					(aluOp),
				//Inputs
				.OpCode					(IFID_instr[15:11]),
				.Funct					(IFID_instr[1:0]),
				.rst					(rst));
	//register file	
	rf_bypass regFile(
				//OutPuts
				.readData1				(regRs),
				.readData2				(regRt),
				.err					(rfErr),
				//Inputs
				.clk					(clk),
				.rst					(rst),
				.readReg1Sel			(IFID_instr[10:8]),
				.readReg2Sel			(IFID_instr[7:5]),
				.writeRegSel			(MEMWB_writeRegSel),
				.writeData				(MEMWB_writeData),
				.writeEn				(MEMWB_RegWrite));
	assign writeRegSel = (RegDst == 2'b00) ? IFID_instr[4:2] :
						 (RegDst == 2'b01) ? IFID_instr[7:5] :
						 (RegDst == 2'b11) ? 3'b111 : 
						 IFID_instr[10:8];
	//control signal for jal instruction;
	assign jalControl = RegDst[1] & RegDst[0];
	//hazard control unit
	//nop & changing
	hazard_detect hazard(
						 .IFID_RsSel	(IFID_instr[10:8]),
						 .IFID_RtSel	(IFID_instr[7:5]),
						 .IDEX_RdSel	(IDEX_writeRegSel),
						 .EXMEM_RdSel	(EXMEM_writeRegSel),
						 .EXMEM_DMemRead(EXMEM_DMemRead),
						 .IFID_jr		(Jump),
						 .EXMEM_RegWrite(EXMEM_RegWrite),
						 .IDEX_RegWrite (IDEX_RegWrite),
						 .IDEX_DMemRead	(IDEX_DMemRead),
						 .IFID_Branch	(PCSrc),
	//notImm is asserted when Rt is a real Rt (add, st)
						 .notImm		(notImm),
						 .usingRs		(usingRs),
						 .stall			(hazardStall));
	//notImm is asserted when Rt is not a real Rt (it's immediate or Rd)
	assign notImm = ~(|ALUSrc2);
	//decide whether Rs is using. EXclude j, jal and nop
	assign usingRs = ~(PCImm | (IFID_instr[15:11] == 5'b00001));
	assign aluReg2 = (ALUSrc2 == 2'b11) ? extend_8 :
					 (ALUSrc2 == 2'b10) ? extend_5 :
					 (ALUSrc2 == 2'b00) ? regRt : 0;

endmodule
