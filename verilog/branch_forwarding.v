module branch_forwarding(EXMEM_RdSel, MEMWB_RdSel, EXMEM_RegWrite, MEMWB_RegWrite,
						 			IFID_RsSel, EXtoD_Rs, MEMtoD_Rs);
	//Inputs
	input [2:0] EXMEM_RdSel;
	input [2:0] MEMWB_RdSel;
	input [2:0] IFID_RsSel;
	input EXMEM_RegWrite;
	input MEMWB_RegWrite;
	//Outputs
	output EXtoD_Rs;
	output MEMtoD_Rs;

	assign EXtoD_Rs = (IFID_RsSel == EXMEM_RdSel) & EXMEM_RegWrite;
	assign MEMtoD_Rs = (IFID_RsSel == MEMWB_RdSel) & MEMWB_RegWrite;
endmodule
