module hazard_detect(IFID_RsSel, IFID_RtSel, IDEX_RdSel, EXMEM_RdSel, EXMEM_DMemRead,
							IFID_jr, EXMEM_RegWrite, IDEX_RegWrite, 
							IDEX_DMemRead, IFID_Branch, notImm, usingRs, stall);
	//Inputs
	input [2:0] IFID_RsSel;
	input [2:0] IFID_RtSel;
	input [2:0] IDEX_RdSel;
	input [2:0] EXMEM_RdSel;
	input IFID_jr;
	input IDEX_RegWrite;
	input IDEX_DMemRead;
	input IFID_Branch;
	input EXMEM_RegWrite;
	input EXMEM_DMemRead;
	//Rt is not reading (or it's a immediate) in the instruction. notImm is used to get rid of this situation.
	//for example: ld 	$r1, 0($r2)
	//			   addi	$r1, $r2, 1
	//Similar situation can happen for jump or instruction.
	input notImm;			//reading Rt or not store (MEM-MEM forwarding)
	input usingRs;			//usingRs is set to 1 if using Rs. For j, jal and nop, it's set to 0.
	//Output
	output stall;
//nop
	assign stall = (((IDEX_DMemRead | IFID_Branch | IFID_jr) & IDEX_RegWrite &
				   (((IFID_RsSel == IDEX_RdSel) & usingRs) //not j, jal or nop (not using rs)
				   //reading Rt or not store (MEM-MEM forwarding)
				   	 | ((IFID_RtSel == IDEX_RdSel) & notImm)))
				   | (EXMEM_DMemRead & EXMEM_RegWrite & (IFID_Branch | IFID_jr) & 
				   (IFID_RsSel == EXMEM_RdSel))) ? 1'b1 : 1'b0;
endmodule
