module cache_control(clk, rst, dirty0, dirty1, busy, write, comp, Done, hit0, hit1, stall, 
					 tagSel, real_hit, mem_offset, memWrite, memRead, offset, 
					 cacheWrite, valid_in, offsetSel, cacheDataSel, cacheEn, miss_rd,
					 valid0, valid1, victim, cacheSel, flush, b_hazard, offsetIn);
	//Inputs
	input clk;
	input rst;
	input cacheEn;
	input valid0;
	input valid1;
	input dirty0;
	input dirty1;
	input [3:0] busy;
	input write;
	input hit0;
	input hit1;
	input victim;
	input flush;			//if flush, stay in IDLE
	input b_hazard;			//if branch needs to stall, stay in IDLE
	input [2:0] offsetIn;
	//Outputs
	output reg comp;
	output reg Done;
	output reg memWrite;
	output reg memRead;
	output reg [2:0] offset;
	output reg [2:0] mem_offset;
	output reg cacheWrite;
	output reg valid_in;
	output reg offsetSel;		//select whether output is from control (0) or Addr (1)
	output reg tagSel;
	output reg stall;
	output reg cacheDataSel;
	output reg real_hit;
	output cacheSel;			//set to 0 when select cache 0
	output reg miss_rd;			//assert when it's in read data from four-bank memory stage

	wire [4:0] state;
	reg [4:0] nxt_state;
	wire test_hit, goto_wr;
	wire test_hit0, test_hit1;
	wire nxt_cacheSel, ff_cacheSel, test_cacheSel;
	wire b_stayInIDLE;			//stay in IDLE because of branch
	reg stayIDLE;
	dff state_dff [4:0] (.q(state), .d(nxt_state), .clk(clk), .rst(rst));
	//states
	parameter IDLE = 0, WR_BANK0 = 1, WR_BANK1 = 2, WR_BANK2 = 3, WR_BANK3 = 4, 
			  RD_BANK0 = 5, RD_BANK1 = 6, RD_BANK2 = 7, RD_BANK3 = 8, 
			  RD_BANK3_HOLD = 9;
	assign test_hit0 = valid0 & hit0;
	assign test_hit1 = valid1 & hit1;
	assign test_hit = test_hit0 | test_hit1;
	assign goto_wr = valid0 & valid1 & ((dirty0 & ~victim) | (dirty1 & victim));
	//set to 1 when select cache 0
	assign test_cacheSel = ~(test_hit0 | (~valid0 | (valid0 & valid1 & ~victim)) & ~test_hit1);
	assign nxt_cacheSel = (test_cacheSel & stayIDLE) | (~stayIDLE & cacheSel);
	assign cacheSel = stayIDLE ? test_cacheSel : ff_cacheSel;
	//latch cacheSel
	dff cacheSel_latch(.q(ff_cacheSel), .d(nxt_cacheSel), .clk(clk), .rst(rst));
	assign b_stayInIDLE = flush | b_hazard;
	always@(*)begin
		comp = 0;
		Done = 0;
		memWrite = 0;
		memRead = 0;
		offset = 0;
		mem_offset = 0;
		cacheWrite = 0;
		valid_in = 0;
		offsetSel = 0;
		tagSel = 0;
		stall = 1'b1;
		cacheDataSel = 0;
		real_hit = 0;
		stayIDLE = 0;
		miss_rd = 0;
		case(state)
			//stay in IDLE if not enable
			//initial siganls for hit or miss
			//if hit, go to stay in IDLE
			//if not hit, go to WR_BANK0 (dirty and valid) or RD_BANK0 (o.w.)
			//if flush or branch stalls, stay in IDLE
			IDLE: begin
				comp = 1'b1;
				stayIDLE = 1'b1;
				memWrite = cacheEn & (goto_wr & ~test_hit) & ~b_stayInIDLE;
				memRead = cacheEn & (~goto_wr & ~test_hit) & ~b_stayInIDLE;
				cacheWrite = cacheEn & test_hit & write & ~b_stayInIDLE;
				valid_in = cacheEn & test_hit & write & ~b_stayInIDLE;
				offsetSel = test_hit;
				tagSel = ~goto_wr;
				stall = cacheEn & ~test_hit & ~b_stayInIDLE;
				Done = cacheEn & test_hit;
				real_hit = test_hit;
				cacheDataSel = 1'b1;
				nxt_state = cacheEn & ~b_stayInIDLE ? (test_hit ? IDLE : 
										(goto_wr ? WR_BANK0 : RD_BANK0)) : IDLE;
			end
			WR_BANK0: begin
			//initial writing to bank1
				mem_offset = 3'b010;
				offset = 3'b010;
				memWrite = 1'b1;
				nxt_state = WR_BANK1;
			end
			WR_BANK1: begin
			//finishing writing bank0
			//initial writing to bank2
				mem_offset = 3'b100;
				offset = 3'b100;
				memWrite = 1'b1;
				nxt_state = WR_BANK2;
			end
			WR_BANK2: begin
			//finishing writing bank1
			//initial writing to bank3
				mem_offset = 3'b110;
				offset = 3'b110;
				memWrite = 1'b1;
				nxt_state = WR_BANK3;
			end
			WR_BANK3: begin
			//finishing writing bank2
			//initial reading from bank0
				mem_offset = 0;
				memRead = 1'b1;
				tagSel = 1'b1;
				nxt_state = RD_BANK0;
			end
			RD_BANK0: begin
			//finishing writing bank3
			//initial reading from bank1
				mem_offset = 3'b010;
				memRead = 1'b1;
				tagSel = 1'b1;
				nxt_state = RD_BANK1;
			end
			RD_BANK1: begin
			//finishing reading bank0
			//initial reading from bank2
			//for a write instruction, select input data to write into cache when offset matches
			//for a read instruction, latch the data from memory, and connect DataOut to it
			//by doing these, Done can be asserted as soon as loading data from four-bank memory is finished
				mem_offset = 3'b100;
				memRead = 1'b1;
				cacheWrite = 1'b1;
				valid_in = 1'b1;
				tagSel = 1'b1;
				nxt_state = RD_BANK2;
				cacheDataSel = write & (offsetIn == 3'b000);
				miss_rd = 1'b1;
			end
			RD_BANK2: begin
			//finishing reading bank1
			//initial reading from bank3
				mem_offset = 3'b110;
				memRead = 1'b1;
				offset = 3'b010;
				cacheWrite = 1'b1;
				valid_in = 1'b1;
				tagSel = 1'b1;
				nxt_state = RD_BANK3;
				cacheDataSel = write & (offsetIn == 3'b010); 
				miss_rd = 1'b1;	
			end
			RD_BANK3: begin
			//finishing reading bank2
			//waiting for finishing reading bank3;
				offset = 3'b100;
				cacheWrite = 1'b1;
				valid_in = 1'b1;
				nxt_state = RD_BANK3_HOLD;
				cacheDataSel = write & (offsetIn == 3'b100);
				miss_rd = 1'b1;
			end
			RD_BANK3_HOLD: begin
			//finishing reading bank3
			//set comp = 1 when it's a write, so that the dirty bit will be set
				comp = write;		
				offset = 3'b110;
				cacheWrite = 1'b1;
				valid_in = 1'b1;
				stall = 0;
				Done = 1'b1;
				miss_rd = 1'b1;		
				cacheDataSel = write & (offsetIn == 3'b110);		
				nxt_state = IDLE;
			end
		endcase
	end
endmodule
