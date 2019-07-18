module IDEX_ff(clk, rst, IDEX_Rs, IDEX_Rt, IDEX_aluReg2, IDEX_RegWrite, IDEX_DMemWrite, IDEX_DMemRead,
				IDEX_MemToReg, IDEX_DMemDump, IDEX_aluOp, IDEX_writeRegSel, IDEX_jalControl, IDEX_RtSel,
				IDEX_RsSel, IDEX_notImm, IDEX_jalPC, hazardStall, DMemStall, RegWrite, DMemWrite,
				DMemDump, jalControl, regRs, regRt, aluReg2, DMemRead, MemToReg, aluOp, writeRegSel,
				IFID_instr, notImm, IFID_PC);

	//Inputs
	input clk;
	input rst;
	input RegWrite;
	input DMemWrite;
	input DMemDump;
	input jalControl;
	input [15:0] regRs;
	input [15:0] regRt;
	input [15:0] aluReg2;
	input DMemRead;
	input MemToReg;
	input [3:0] aluOp;
	input [2:0] writeRegSel;
	input notImm;
	input [15:0] IFID_PC;
	input [15:0] IFID_instr;
	input hazardStall;
	input DMemStall;
	//Outputs
	output [15:0] IDEX_Rs;
	output [15:0] IDEX_Rt;
	output [15:0] IDEX_aluReg2;
	output IDEX_RegWrite;
	output IDEX_DMemWrite;
	output IDEX_DMemRead;
	output IDEX_MemToReg;		
	output IDEX_DMemDump;
	output [3:0] IDEX_aluOp;
	output [2:0] IDEX_writeRegSel;
	output IDEX_jalControl;
	output [2:0] IDEX_RtSel;
	output [2:0] IDEX_RsSel;
	output IDEX_notImm;
	output [15:0] IDEX_jalPC;

    wire [15:0] stall_regRs;
    wire [15:0] stall_regRt;
    wire [15:0] stall_aluReg2;
    wire stall_DMemRead, stall_MemToReg, stall_notImm;
    wire [3:0] stall_aluOp;
    wire [2:0] stall_writeRegSel;
    wire [2:0] stall_RtSel;
    wire [2:0] stall_RsSel;
    wire [15:0] stall_IFID_PC;
	wire stall_RegWrite, stall_DMemWrite, stall_DMemDump, stall_jalControl;

    //Rs ff
    ff_16b ff_IDEX_Rs(.clk(clk), .rst(rst), .data_in(stall_regRs), .data_out(IDEX_Rs));
    //Rt ff
    ff_16b ff_IDEX_Rt(.clk(clk), .rst(rst), .data_in(stall_regRt), .data_out(IDEX_Rt));
    //Rt ff
    ff_16b ff_IDEX_aluReg2(.clk(clk), .rst(rst), .data_in(stall_aluReg2), .data_out(IDEX_aluReg2));
    //ff for control signals
    dff ff_IDEX_RegWrite(.q(IDEX_RegWrite), .d(stall_RegWrite), .clk(clk), .rst(rst));
    dff ff_IDEX_DMemWrite(.q(IDEX_DMemWrite), .d(stall_DMemWrite), .clk(clk), .rst(rst));
    dff ff_IDEX_DMemRead(.q(IDEX_DMemRead), .d(stall_DMemRead), .clk(clk), .rst(rst));
    dff ff_IDEX_MemToReg(.q(IDEX_MemToReg), .d(stall_MemToReg), .clk(clk), .rst(rst));
    dff ff_IDEX_DMemDump(.q(IDEX_DMemDump), .d(stall_DMemDump), .clk(clk), .rst(rst));
    dff ff_IDEX_aluOp [3:0] (.q(IDEX_aluOp), .d(stall_aluOp), .clk(clk), .rst(rst));
    dff ff_IDEX_writeRegSel [2:0] (.q(IDEX_writeRegSel), .d(stall_writeRegSel), .clk(clk), .rst(rst));
    dff ff_IDEX_jalControl(.q(IDEX_jalControl), .d(stall_jalControl), .clk(clk), .rst(rst));
    //RtSel ff
    dff ff_IDEX_RtSel [2:0] (.q(IDEX_RtSel), .d(stall_RtSel), .clk(clk), .rst(rst));
    //RsSel ff
    dff ff_IDEX_RsSel [2:0] (.q(IDEX_RsSel), .d(stall_RsSel), .clk(clk), .rst(rst));
    //notImm ff
    dff ff_IDEX_notImm(.q(IDEX_notImm), .d(stall_notImm), .clk(clk), .rst(rst));
    //(PC + 2) ff for jal instruction
    ff_16b ff_IDEX_PC(.clk(clk), .rst(rst), .data_in(stall_IFID_PC), .data_out(IDEX_jalPC));
    //if stall, send an nop.
	//the priority of stalls is: DMemStall > hazardStall > IMemStall
    assign stall_RegWrite = DMemStall ? IDEX_RegWrite : (hazardStall ? 1'b0 : RegWrite);
    assign stall_DMemWrite = DMemStall ? IDEX_DMemWrite : (hazardStall ? 1'b0 : DMemWrite);
    assign stall_DMemDump = DMemStall ? IDEX_DMemDump : (hazardStall ? 1'b0 : DMemDump);
    assign stall_jalControl = DMemStall ? IDEX_jalControl : (hazardStall ? 1'b0 : jalControl);
    assign stall_regRs = DMemStall ? IDEX_Rs : (hazardStall ? 1'b0 : regRs);
    assign stall_regRt = DMemStall ? IDEX_Rt : (hazardStall ? 1'b0 : regRt);
    assign stall_aluReg2 = DMemStall ? IDEX_aluReg2 : (hazardStall ? 1'b0 : aluReg2);
    assign stall_DMemRead = DMemStall ? IDEX_DMemRead : (hazardStall ? 1'b0 : DMemRead);
    assign stall_MemToReg = DMemStall ? IDEX_MemToReg : (hazardStall ? 1'b0 : MemToReg);
    assign stall_aluOp = DMemStall ? IDEX_aluOp : (hazardStall ? 1'b0 : aluOp);
    assign stall_writeRegSel = DMemStall ? IDEX_writeRegSel : (hazardStall ? 1'b0 : writeRegSel);
    assign stall_RtSel = DMemStall ? IDEX_RtSel : (hazardStall ? 1'b0 : IFID_instr[7:5]);
    assign stall_RsSel = DMemStall ? IDEX_RsSel : (hazardStall ? 1'b0 : IFID_instr[10:8]);
    assign stall_notImm = DMemStall ? IDEX_notImm : (hazardStall ? 1'b0 : notImm);
    assign stall_IFID_PC = DMemStall ? IDEX_jalPC : (hazardStall ? 1'b0 : IFID_PC);

endmodule
