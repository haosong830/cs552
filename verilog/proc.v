/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   	// Outputs
   	err, 
   	// Inputs
   	clk, rst
   	);

   	input clk;
   	input rst;

   	output err;

   	// None of the above lines can be modified

   	// OR all the err ouputs for every sub-module and assign it as this
   	// err output
   
   	// As desribed in the homeworks, use the err signal to trap corner
   	// cases that you think are illegal in your statemachines
   
   
   	/* your code here */
   	wire [15:0] instrData_out;
	wire [15:0] IFID_PC;
	wire [15:0] IFID_instr;
	wire IDEX_RegWrite, IDEX_DMemWrite, IDEX_DMemRead, IDEX_DMemDump, IDEX_MemToReg;
	wire MEMWB_DMemDump, EXMEM_DMemDump;
	wire RegWrite, DMemWrite, DMemRead, PCSrc,
		 PCImm, MemToReg, DMemDump, Jump;
	wire [15:0] IDEX_Rs;
	wire [15:0] IDEX_Rt;
	wire [15:0] EXMEM_exOut;
	wire [15:0] EXMEM_Rt;
	wire [3:0] IDEX_aluOp;
	wire MEMWB_RegWrite, MEMWB_MemToReg;
	wire [15:0] MEMWB_mem_out;
	wire [15:0] MEMWB_exOut;
	wire [2:0] MEMWB_writeRegSel;
	wire [15:0] MEMWB_writeData;
	wire jalControl;
	wire IDEX_jalControl;
	wire [2:0] IDEX_writeRegSel;
	wire [15:0] exOut;
	wire Ofl;
	wire [3:0] aluOp;
	wire [2:0] writeRegSel;
	wire [15:0] regRs;
	wire [15:0] regRt;
	wire [15:0] aluReg2;
	wire [15:0] IDEX_jalPC;
	wire [15:0] mem_out;
	wire [15:0] PC_add_2;
	wire [15:0] jr_PC;
	wire branchDeci;				//decide take the branch or not
	wire hazardStall;
	wire flush;
	wire notImm, IDEX_notImm;
	wire [2:0] IDEX_RtSel;
	wire [2:0] IDEX_RsSel;
	wire [2:0] EXMEM_RtSel;
	wire [2:0] EXMEM_writeRegSel;
	wire [15:0] forwarding_mem_in;
	wire [15:0] IDEX_aluReg2;
	wire [15:0] forwarding_MEMtoEX_Rt;
	wire EXMEM_DMemWrite, EXMEM_DMemRead, EXMEM_MemToReg;
	wire DMemErr, conErr, rfErr, IMemErr;
	//wire for stalling memory. Don't know what they mean.
	wire IMemDone, DMemDone, IMemStall, DMemStall;
	wire MEMWB_MEMtoMEM_forwarding_RegWrite, EXMEM_MEMtoMEM_forwarding_RegWrite;
	wire DMemHit, IMemHit;
	wire DMemEn;
	wire MEMtoMEM_Rt;

/////////////////////////////////////////////////////////////////////////////////////
//IF stage
//PC is calculated in this stage
//fetch instructions in this stage
	Fetch Fetch(//Inputs
				.clk(clk),
				.rst(rst),
				.DMemDump(DMemDump),
				.MEMWB_DMemDump(MEMWB_DMemDump),
				.hazardStall(hazardStall),
				.DMemStall(DMemStall),
				.PCSrc(PCSrc),
				.branchDeci(branchDeci),
				.PCImm(PCImm),
				.Jump(Jump),
				.flush(flush),
				.jr_PC(jr_PC),
				//Outputs
				.IMemStall(IMemStall),
				.IMemDone(IMemDone),
				.IMemErr(IMemErr),
				.IMemHit(IMemHit),
				.PC_add_2(PC_add_2),
				.instrData_out(instrData_out));

////////////////////////////////////////////////////////////////////////////////////
//IF/ID ff
	IFID_ff IFID(
				 //Inputs
				 .clk					(clk),
				 .rst					(rst),
				 .PC_add_2				(PC_add_2),
				 .DMemStall				(DMemStall),
				 .hazardStall			(hazardStall),
				 .IMemStall				(IMemStall),
				 .flush					(flush),
				 .instrData_out			(instrData_out),
				 .DMemDump				(DMemDump),
				 .err					(err),
				 //Outputs
				 .IFID_PC				(IFID_PC),
				 .IFID_instr			(IFID_instr));
	//set err when any error signal is emitted
	assign err = DMemErr | conErr | rfErr | IMemErr;

///////////////////////////////////////////////////////////////////////////////////
//Id stage
//assign control signals
//hazard detection
//EX-D and MEM-D forwarding (branch)
	Decode Decode(//Inputs
				  .rst(rst),
				  .clk(clk),
				  .IFID_PC(IFID_PC),
				  .IFID_instr(IFID_instr),
				  .IDEX_writeRegSel(IDEX_writeRegSel),
				  .EXMEM_writeRegSel(EXMEM_writeRegSel),
				  .MEMWB_writeRegSel(MEMWB_writeRegSel),
				  .MEMWB_writeData(MEMWB_writeData),
				  .MEMWB_RegWrite(MEMWB_RegWrite),
				  .MEMWB_MEMtoMEM_forwarding_RegWrite(MEMWB_MEMtoMEM_forwarding_RegWrite),
				  .EXMEM_DMemRead(EXMEM_DMemRead),
				  .EXMEM_RegWrite(EXMEM_RegWrite),
				  .IDEX_RegWrite(IDEX_RegWrite),
				  .IDEX_DMemRead(IDEX_DMemRead),
				  .EXMEM_exOut(EXMEM_exOut),
				  .PC_add_2(PC_add_2),
				  //Outputs
				  .RegWrite(RegWrite),
				  .DMemWrite(DMemWrite),
				  .DMemRead(DMemRead),
				  .PCSrc(PCSrc),
				  .PCImm(PCImm),
				  .MemToReg(MemToReg),
				  .DMemDump(DMemDump),
				  .Jump(Jump),
				  .writeRegSel(writeRegSel),
				  .aluOp(aluOp),
				  .hazardStall(hazardStall),
				  .notImm(notImm),
				  .jalControl(jalControl),
				  .aluReg2(aluReg2),
				  .branchDeci(branchDeci),
				  .regRs(regRs),
				  .regRt(regRt),
				  .jr_PC(jr_PC),
				  .flush(flush),
				  .rfErr(rfErr),
				  .conErr(conErr));

///////////////////////////////////////////////////////////////////////////////////
//ID/EX ff
	IDEX_ff IDEX(
				 //Inputs
				 .clk					(clk),
				 .rst					(rst),
				 .RegWrite				(RegWrite),
				 .DMemWrite				(DMemWrite),
				 .DMemDump				(DMemDump),
				 .jalControl			(jalControl),
				 .regRs					(regRs),
				 .regRt					(regRt),
				 .aluReg2				(aluReg2),
				 .DMemRead				(DMemRead),
				 .MemToReg				(MemToReg),
				 .aluOp					(aluOp),
				 .writeRegSel			(writeRegSel),
				 .notImm				(notImm),
				 .IFID_PC				(IFID_PC),
				 .IFID_instr			(IFID_instr),
				 .hazardStall			(hazardStall),
				 .DMemStall				(DMemStall),
				 //Outputs
				 .IDEX_Rs				(IDEX_Rs),
				 .IDEX_Rt				(IDEX_Rt),
				 .IDEX_aluReg2			(IDEX_aluReg2),
				 .IDEX_RegWrite			(IDEX_RegWrite),
				 .IDEX_DMemWrite		(IDEX_DMemWrite),
				 .IDEX_DMemRead			(IDEX_DMemRead),
				 .IDEX_MemToReg			(IDEX_MemToReg),
				 .IDEX_DMemDump			(IDEX_DMemDump),
				 .IDEX_aluOp			(IDEX_aluOp),
				 .IDEX_writeRegSel		(IDEX_writeRegSel),
				 .IDEX_jalControl		(IDEX_jalControl),
				 .IDEX_RtSel			(IDEX_RtSel),
				 .IDEX_RsSel			(IDEX_RsSel),
				 .IDEX_notImm			(IDEX_notImm),
				 .IDEX_jalPC			(IDEX_jalPC));

///////////////////////////////////////////////////////////////////////////////////
//EX stage
//EX-EX and EX-MEM forwarding
//alu unit
	Execute Execute(//Inputs
					.IDEX_aluOp(IDEX_aluOp),
					.IDEX_jalControl(IDEX_jalControl),
					.IDEX_jalPC(IDEX_jalPC),
					.IDEX_RtSel(IDEX_RtSel),
					.IDEX_RsSel(IDEX_RsSel),
					.EXMEM_writeRegSel(EXMEM_writeRegSel),
					.MEMWB_writeRegSel(MEMWB_writeRegSel),
					.EXMEM_RegWrite(EXMEM_RegWrite),
					.MEMWB_MEMtoMEM_forwarding_RegWrite(MEMWB_MEMtoMEM_forwarding_RegWrite),
					.IDEX_notImm(IDEX_notImm),
					.IDEX_Rs(IDEX_Rs),
					.IDEX_aluReg2(IDEX_aluReg2),
					.IDEX_Rt(IDEX_Rt),
					.MEMWB_writeData(MEMWB_writeData),
					.EXMEM_exOut(EXMEM_exOut),
					.Ofl(Ofl),
					.exOut(exOut),
					.forwarding_MEMtoEX_Rt(forwarding_MEMtoEX_Rt),
					.clk(clk),
					.rst(rst));

///////////////////////////////////////////////////////////////////////////////////
//EX/MEM ff
	EXMEM_ff EXMEM(
				   //Inputs
				   .clk					(clk),
				   .rst					(rst),
				   .exOut				(exOut),
				   .MEMtoEX_Rt			(forwarding_MEMtoEX_Rt),
				   .IDEX_RegWrite		(IDEX_RegWrite),
				   .IDEX_DMemWrite		(IDEX_DMemWrite),
				   .IDEX_DMemRead		(IDEX_DMemRead),
				   .IDEX_MemToReg		(IDEX_MemToReg),
				   .IDEX_DMemDump		(IDEX_DMemDump),
				   .IDEX_writeRegSel	(IDEX_writeRegSel),
				   .IDEX_RtSel			(IDEX_RtSel),
				   .DMemStall			(DMemStall),
				   //Outputs
				   .EXMEM_exOut			(EXMEM_exOut),
				   .EXMEM_Rt			(EXMEM_Rt),
				   .EXMEM_RegWrite		(EXMEM_RegWrite),
				   .EXMEM_DMemWrite		(EXMEM_DMemWrite),
				   .EXMEM_DMemRead		(EXMEM_DMemRead),
				   .EXMEM_MemToReg		(EXMEM_MemToReg),
				   .EXMEM_DMemDump		(EXMEM_DMemDump),
				   .EXMEM_writeRegSel	(EXMEM_writeRegSel),
				   .EXMEM_RtSel			(EXMEM_RtSel));

///////////////////////////////////////////////////////////////////////////////////
//MEM stage
	//Data memory
	assign DMemEn = (EXMEM_DMemRead | EXMEM_DMemWrite) & ~rst;
	mem_system #(1) dataMem(
					   //Outputs
					   .DataOut			(mem_out),
					   .Done			(DMemDone),
					   .Stall			(DMemStall),
					   .CacheHit		(DMemHit),
					   .err				(DMemErr),
					   //Inputs
					   .flush			(1'b0),				//never flush data memory
					   .b_hazard		(1'b0),
					   .Addr			(EXMEM_exOut),
					   .DataIn          (forwarding_mem_in),
					   .Rd              (EXMEM_DMemRead),
					   .Wr              (EXMEM_DMemWrite),
					   .createdump      (MEMWB_DMemDump),
					   .clk             (clk),
					   .rst             (rst));
	//forwarding control for MEM-MEM forwarding (store after load)
	assign forwarding_mem_in = MEMtoMEM_Rt ? MEMWB_writeData : EXMEM_Rt;
	assign MEMtoMEM_Rt = (EXMEM_RtSel == MEMWB_writeRegSel) & MEMWB_MEMtoMEM_forwarding_RegWrite & EXMEM_DMemWrite;
	//Since we cannot write to same register file for multiple times, and RegWrite siganl is used to select MEM-MEM forwarding.
	//Connect a new signal to the EXMEM_RegWrite and latch the new signal. Use that new signal to select MEM-MEM forwarding.
	assign EXMEM_MEMtoMEM_forwarding_RegWrite = EXMEM_RegWrite;

///////////////////////////////////////////////////////////////////////////////////
//MEM/WB ff
	MEMWB_ff MEMWB(
				   //inputs
				   .clk					(clk),
				   .rst					(rst),
				   .EXMEM_RegWrite		(EXMEM_RegWrite),
				   .EXMEM_writeRegSel	(EXMEM_writeRegSel),
				   .EXMEM_exOut			(EXMEM_exOut),
				   .mem_out				(mem_out),
				   .EXMEM_MemToReg		(EXMEM_MemToReg),
				   .EXMEM_DMemDump		(EXMEM_DMemDump),
				   .EXMEM_for_RegWrite	(EXMEM_MEMtoMEM_forwarding_RegWrite),
				   .DMemStall			(DMemStall),
				   //Outputs
				   .MEMWB_RegWrite		(MEMWB_RegWrite),
				   .MEMWB_writeRegSel	(MEMWB_writeRegSel),
				   .MEMWB_exOut			(MEMWB_exOut),
				   .MEMWB_mem_out		(MEMWB_mem_out),
				   .MEMWB_MemToReg		(MEMWB_MemToReg),
				   .MEMWB_DMemDump		(MEMWB_DMemDump),
				   .MEMWB_for_RegWrite	(MEMWB_MEMtoMEM_forwarding_RegWrite));
	//use MEM date or alu result for write back
	assign MEMWB_writeData = MEMWB_MemToReg ? MEMWB_mem_out : MEMWB_exOut;

///////////////////////////////////////////////////////////////////////////////////
endmodule
// proc
// DUMMY LINE FOR REV CONTROL :0:
