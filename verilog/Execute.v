module Execute(//Inputs
			  input [3:0] IDEX_aluOp,
			  input IDEX_jalControl,
			  input [15:0] IDEX_jalPC,
			  input [2:0] IDEX_RtSel,
			  input [2:0] IDEX_RsSel,
			  input [2:0] EXMEM_writeRegSel,
			  input [2:0] MEMWB_writeRegSel,
			  input EXMEM_RegWrite,
			  input MEMWB_MEMtoMEM_forwarding_RegWrite,
			  input IDEX_notImm,
			  input [15:0] IDEX_Rs,
			  input [15:0] IDEX_aluReg2,
			  input [15:0] IDEX_Rt,
			  input [15:0] MEMWB_writeData,
			  input [15:0] EXMEM_exOut,
			  input clk,
			  input rst,
			  //Outputs
			  output Ofl,
			  output [15:0] exOut,
			  output [15:0] forwarding_MEMtoEX_Rt
			  );
	wire [15:0] forwarding_alu_Rs;
	wire [15:0] forwarding_alu_aluReg2;
	wire [15:0] aluOut;
	wire Zero;
	wire EXtoEX_Rs, EXtoEX_Rt, MEMtoEX_Rt, MEMtoEX_Rs, MEMtoMEM_Rt;
	wire Ofl_sync;
	wire [15:0] exOut_sync;
	wire [15:0] forwarding_MEMtoEX_Rt_sync;
	dff f0(clk,1'b0,Ofl_sync,Ofl);
	ff_16b f1(clk,1'b0,exOut_sync,exOut);
	ff_16b f2(clk,1'b0,forwarding_MEMtoEX_Rt_sync,forwarding_MEMtoEX_Rt);
	alu alu_unit(
				 //Inputs
				 .A						(forwarding_alu_Rs),
				 .B						(forwarding_alu_aluReg2),
				 .Op					(IDEX_aluOp),
				 .clk					(clk),
				 .rst					(rst),
				 //Outputs
				 .Out					(aluOut),
				 .Zero					(Zero),
				 
				 .Ofl					(Ofl_sync));
	//choose to pass (PC + 2) for jal instruction or alu output
	assign exOut_sync = IDEX_jalControl ? IDEX_jalPC : aluOut;
	//forwarding unit for EX-EX forwarding and MEM-EX forwarding
	forwarding_unit f(
					  //Inputs
					  .IDEX_RtSel		(IDEX_RtSel),
					  .IDEX_RsSel		(IDEX_RsSel),
					  .EXMEM_RdSel		(EXMEM_writeRegSel),
					  .MEMWB_RdSel		(MEMWB_writeRegSel),
					  .EXMEM_RegWrite	(EXMEM_RegWrite),
					  .MEMWB_RegWrite	(MEMWB_MEMtoMEM_forwarding_RegWrite),
					  .notImm			(IDEX_notImm),
					  //Outputs
					  .EXtoEX_Rs		(EXtoEX_Rs),
					  .EXtoEX_Rt		(EXtoEX_Rt),
					  .MEMtoEX_Rt		(MEMtoEX_Rt),
					  .MEMtoEX_Rs		(MEMtoEX_Rs));
	assign forwarding_alu_Rs = EXtoEX_Rs ? EXMEM_exOut :
							   (MEMtoEX_Rs ? MEMWB_writeData : 
							   IDEX_Rs);
	assign forwarding_alu_aluReg2 = EXtoEX_Rt ? EXMEM_exOut : 
							   (MEMtoEX_Rt ? MEMWB_writeData :
							   IDEX_aluReg2);
	//forwarding Rt for st instruction
	assign forwarding_MEMtoEX_Rt_sync = ((IDEX_RtSel == MEMWB_writeRegSel) & MEMWB_MEMtoMEM_forwarding_RegWrite) ? 
									MEMWB_writeData : IDEX_Rt;
endmodule
