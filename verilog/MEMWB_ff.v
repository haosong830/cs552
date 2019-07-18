module MEMWB_ff(clk, rst, EXMEM_RegWrite, EXMEM_exOut, mem_out, EXMEM_writeRegSel, 
				EXMEM_MemToReg, EXMEM_DMemDump, EXMEM_for_RegWrite, DMemStall,
				MEMWB_RegWrite, MEMWB_writeRegSel, MEMWB_exOut, MEMWB_mem_out, 
				MEMWB_MemToReg, MEMWB_for_RegWrite, MEMWB_DMemDump);
	//Inputs
	input clk;
	input rst;
	input EXMEM_RegWrite;
	input [2:0] EXMEM_writeRegSel;
	input [15:0] EXMEM_exOut;
	input [15:0] mem_out;
	input EXMEM_MemToReg;
	input EXMEM_DMemDump;
	input EXMEM_for_RegWrite;
	input DMemStall;
	//Outputs
	output MEMWB_RegWrite;
	output [2:0] MEMWB_writeRegSel;
	output [15:0] MEMWB_exOut;
	output [15:0] MEMWB_mem_out;
	output MEMWB_MemToReg;
	output MEMWB_DMemDump;
	output MEMWB_for_RegWrite;

	wire stall_EXMEM_RegWrite;
	wire [2:0] stall_EXMEM_writeRegSel;
	wire [15:0] stall_EXMEM_exOut;
	wire [15:0] stall_mem_out;
	wire stall_EXMEM_MemToReg;
	wire stall_EXMEM_DMemDump;
	wire stall_EXMEM_for_RegWrite;
	
    //ff for write-back control
    dff ff_MEMWB_RegWrite(.q(MEMWB_RegWrite), .d(stall_EXMEM_RegWrite), .clk(clk), .rst(rst));
    dff ff_MEMWB_writeRegSel [2:0] (.q(MEMWB_writeRegSel), .d(stall_EXMEM_writeRegSel), .clk(clk), .rst(rst));
    //exOut ff
    ff_16b ff_MEMWB_exOut(.clk(clk), .rst(rst), .data_in(stall_EXMEM_exOut), .data_out(MEMWB_exOut));
    //mem_out ff
    ff_16b ff_MEMWB_mem_out(.clk(clk), .rst(rst), .data_in(stall_mem_out), .data_out(MEMWB_mem_out));
    //MemToReg ff
    dff ff_MEMWB_MemToReg(.q(MEMWB_MemToReg), .d(stall_EXMEM_MemToReg), .clk(clk), .rst(rst));
    //DMemDump ff
    dff ff_MEMWB_DMemDump(.q(MEMWB_DMemDump), .d(stall_EXMEM_DMemDump), .clk(clk), .rst(rst));
	//RegWrite for forwarding ff
	dff ff_MEMWB_for_Regwrite(.q(MEMWB_for_RegWrite), .d(stall_EXMEM_for_RegWrite), .clk(clk), .rst(rst));
	//latch the same value to the WB-stage when data memory stalls
	//by doing this MEM-MEM forwarding can work
	//send RegWrite to be 1'b0, so that there won't be multiple write into reg file
	assign stall_EXMEM_RegWrite = DMemStall ? 1'b0 : EXMEM_RegWrite;
	assign stall_EXMEM_for_RegWrite = DMemStall ? MEMWB_for_RegWrite : EXMEM_for_RegWrite;
	assign stall_EXMEM_writeRegSel = DMemStall ? MEMWB_writeRegSel : EXMEM_writeRegSel;
	assign stall_EXMEM_exOut = DMemStall ? MEMWB_exOut : EXMEM_exOut;
	assign stall_mem_out = DMemStall ? MEMWB_mem_out : mem_out;
	assign stall_EXMEM_MemToReg = DMemStall ? MEMWB_MemToReg : EXMEM_MemToReg;
	assign stall_EXMEM_DMemDump = DMemStall ? 1'b0 : EXMEM_DMemDump;

endmodule
