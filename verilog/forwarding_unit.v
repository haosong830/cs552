//forwarding unit for EX-EX forwarding and MEM-EX forwarding
module forwarding_unit(IDEX_RtSel, IDEX_RsSel, EXMEM_RdSel, MEMWB_RdSel, 
					 	 EXMEM_RegWrite, MEMWB_RegWrite, notImm, EXtoEX_Rs, 
					 	 EXtoEX_Rt, MEMtoEX_Rt, MEMtoEX_Rs);
	//Inputs
	input [2:0] IDEX_RtSel;
	input [2:0] IDEX_RsSel;
	input [2:0] EXMEM_RdSel;
	input [2:0] MEMWB_RdSel;
	input EXMEM_RegWrite;
	input MEMWB_RegWrite;
	//Rt is not reading (or it's a immediate) in the instruction. notImm is used to get rid of this situation.
	//for example: ld   $r1, 0($r2)
	//             addi $r1, $r2, 1
	//Similar situation can happen for jump or instruction.
	input notImm;
	//Outputs
	output EXtoEX_Rs;
	output EXtoEX_Rt;
	output MEMtoEX_Rt;
	output MEMtoEX_Rs;

	assign EXtoEX_Rt = (IDEX_RtSel == EXMEM_RdSel) & EXMEM_RegWrite & notImm; 
	assign EXtoEX_Rs = (IDEX_RsSel == EXMEM_RdSel) & EXMEM_RegWrite;
	assign MEMtoEX_Rt = (IDEX_RtSel == MEMWB_RdSel) & MEMWB_RegWrite & notImm;
	assign MEMtoEX_Rs = (IDEX_RsSel == MEMWB_RdSel) & MEMWB_RegWrite;
endmodule
