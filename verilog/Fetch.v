module Fetch(
			//Inputs
			input clk, rst,								//clk signals
			input DMemDump, MEMWB_DMemDump,				//dumpFile signals	
			input hazardStall, DMemStall,				//stall signals
			input PCSrc, branchDeci, PCImm, Jump, flush,//branch signals
			input [15:0] jr_PC,							//jump address
			//Outputs
			output IMemStall, IMemErr, IMemHit, IMemDone,
			output [15:0] PC_add_2,
			output [15:0] instrData_out
			);

	wire IMemEn, pc_C_out;
	wire [15:0] PC;
	wire [15:0] halt_PC;
	wire [15:0] instrData_in;
	wire [15:0] stall_PC;
	//if HALT, the PC remains unchanged	
	assign halt_PC =  DMemDump ? PC : jr_PC;
	//if rst, PC = 0
	ff_16b current_pc(.clk(clk), .rst(rst), .data_in(stall_PC), .data_out(PC));
	//if it's a hazard stall, PC doesn't change. 
	//If it's branch, jump or other instructions, latch the corresponding PC
	//the priority of stalls is: DMemStall > hazardStall > IMemStall
	assign stall_PC = (hazardStall | DMemStall) ? PC :(IMemStall ? 
					  ((PCSrc & branchDeci) | PCImm | Jump ? halt_PC : PC) : halt_PC);
								  
	//PC + 2
	cla_16b pc_2(
				 .A						(PC),
				 .B						(16'b0000000000000010),
				 .C_in					(1'b0),
				 .S						(PC_add_2),
				 .C_out					(pc_C_out));
	//Instruction memory
	assign IMemEn = ~MEMWB_DMemDump & ~rst;
   	mem_system #(0) instrMem(
					  //Outputs
					  .DataOut			(instrData_out), 
					  .Done				(IMemDone),
					  .Stall			(IMemStall),
					  .CacheHit			(IMemHit),
					  .err				(IMemErr),
					  //Inputs
					  .flush			(flush),				//if flush is asserted, stay in IDLE
					  //if branch needs to stall, stay in IDLE
					  .b_hazard			(PCSrc & hazardStall),	
					  .DataIn			(instrData_in), 
                      .Addr				(PC), 
					  .Rd				(IMemEn), 		//can always access instr mem except for HALT
					  .Wr				(1'b0), 			//can't write instr mem
           			  .createdump		(MEMWB_DMemDump), 
					  .clk				(clk), 
					  .rst				(rst));
endmodule
