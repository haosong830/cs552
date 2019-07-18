module EXMEM_ff(clk, rst, EXMEM_exOut, EXMEM_Rt, EXMEM_RegWrite, EXMEM_DMemWrite, EXMEM_DMemRead, 
		EXMEM_MemToReg, EXMEM_DMemDump, EXMEM_writeRegSel, EXMEM_RtSel, exOut, DMemStall,
		MEMtoEX_Rt, IDEX_RegWrite, IDEX_DMemWrite, IDEX_DMemRead,
		IDEX_MemToReg, IDEX_DMemDump, IDEX_writeRegSel, IDEX_RtSel);
	//Inputs
	input clk;
	input rst;
	input [15:0] exOut;
	input [15:0] MEMtoEX_Rt;
	input IDEX_RegWrite;
	input IDEX_DMemWrite;
	input IDEX_DMemRead;
	input IDEX_MemToReg;
	input IDEX_DMemDump;
	input [2:0] IDEX_writeRegSel;
	input [2:0] IDEX_RtSel;
	input DMemStall;
	//Outputs
	output [15:0] EXMEM_exOut;
	output [15:0] EXMEM_Rt;
	output EXMEM_RegWrite;
	output EXMEM_DMemWrite;
	output EXMEM_DMemRead;
	output EXMEM_MemToReg;
	output EXMEM_DMemDump;
	output [2:0] EXMEM_writeRegSel;
	output [2:0] EXMEM_RtSel;

	wire [15:0] stall_exOut;
	wire [15:0] stall_MEMtoEX_Rt;
	wire stall_IDEX_RegWrite;
	wire stall_IDEX_DMemWrite;
	wire stall_IDEX_DMemRead;
	wire stall_IDEX_MemToReg;
	wire stall_IDEX_DMemDump;
	wire [2:0] stall_IDEX_writeRegSel;
	wire [2:0] stall_IDEX_RtSel;

    //ff for ex-stage
    ff_16b ff_EXMEM_ex(.clk(clk), .rst(rst), .data_in(stall_exOut), .data_out(EXMEM_exOut));
    //Rt ff in EX/MEM
    ff_16b ff_EXMEM_Rt(.clk(clk), .rst(rst), .data_in(stall_MEMtoEX_Rt), .data_out(EXMEM_Rt));
    //ff for control signals
    dff ff_EXMEM_RegWrite(.q(EXMEM_RegWrite), .d(stall_IDEX_RegWrite), .clk(clk), .rst(rst)); 
    dff ff_EXMEM_DMemWrite(.q(EXMEM_DMemWrite), .d(stall_IDEX_DMemWrite), .clk(clk), .rst(rst)); 
    dff ff_EXMEM_DMemRead(.q(EXMEM_DMemRead), .d(stall_IDEX_DMemRead), .clk(clk), .rst(rst)); 
    dff ff_EXMEM_MemToReg(.q(EXMEM_MemToReg), .d(stall_IDEX_MemToReg), .clk(clk), .rst(rst)); 
    dff ff_EXMEM_DMemDump(.q(EXMEM_DMemDump), .d(stall_IDEX_DMemDump), .clk(clk), .rst(rst)); 
    dff ff_EXMEM_writeRegSel [2:0] (.q(EXMEM_writeRegSel), .d(stall_IDEX_writeRegSel), .clk(clk), .rst(rst));
    //EXMEM_RtSel ff
    dff ff_EXMEM_RtSel [2:0] (.q(EXMEM_RtSel), .d(stall_IDEX_RtSel), .clk(clk), .rst(rst));
	//if data memory stalls, execute same Inst. again
	assign stall_exOut = DMemStall ? EXMEM_exOut : exOut;
	assign stall_MEMtoEX_Rt = DMemStall ? EXMEM_Rt : MEMtoEX_Rt;
	assign stall_IDEX_RegWrite = DMemStall ? EXMEM_RegWrite : IDEX_RegWrite;
	assign stall_IDEX_DMemWrite = DMemStall ? EXMEM_DMemWrite : IDEX_DMemWrite;
	assign stall_IDEX_DMemRead = DMemStall ? EXMEM_DMemRead : IDEX_DMemRead;
	assign stall_IDEX_MemToReg = DMemStall ? EXMEM_MemToReg : IDEX_MemToReg;
	assign stall_IDEX_DMemDump = DMemStall ? EXMEM_DMemDump : IDEX_DMemDump;
	assign stall_IDEX_writeRegSel = DMemStall ? EXMEM_writeRegSel : IDEX_writeRegSel;
	assign stall_IDEX_RtSel = DMemStall ? EXMEM_RtSel : IDEX_RtSel;
endmodule
