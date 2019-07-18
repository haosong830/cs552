module IFID_ff(clk, rst, IFID_PC, IFID_instr, err, DMemDump, flush, IMemStall, 
					hazardStall, DMemStall, PC_add_2, instrData_out);
	//Inputs
	input [15:0] PC_add_2;
	input [15:0] instrData_out;
	input clk;
	input rst;
	input DMemStall;
	input hazardStall;
	input IMemStall;
	input flush;
	input DMemDump;
	input err;
	//Outputs
	output [15:0] IFID_PC;
	output [15:0] IFID_instr;

	wire [15:0] IF_instr;
	wire [15:0] stall_IFID_PC;
	wire IFID_stall;
	
	assign IFID_stall = DMemStall | hazardStall;
    //if stall, decode the same instruction. If flush, insert a nop;
    //if halt, insert halt to pipeline to make sure won't execute other instructions
	//the priority of stalls is: DMemStall > hazardStall > IMemStall
	assign IF_instr = IFID_stall ? IFID_instr :
					  (flush | rst | IMemStall) ? 16'b0000100000000000 :
					  DMemDump | err ? 16'b0 : instrData_out;
	//fetch the same Inst. for memory stalls and hazard stalls
	assign stall_IFID_PC =  IFID_stall | IMemStall ? IFID_PC : PC_add_2;
    //IF/ID ff for PC + 2
    ff_16b ff_IFID_PC(.clk(clk), .rst(rst), .data_in(stall_IFID_PC), .data_out(IFID_PC));
    //IF/ID ff for instruction memory
    ff_16b ff_IFID_instr(.clk(clk), .rst(1'b0), .data_in(IF_instr), .data_out(IFID_instr));
 

endmodule
