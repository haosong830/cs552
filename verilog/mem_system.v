/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err, 
   // Inputs
   b_hazard, flush, Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input flush;
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   input 		b_hazard;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   wire [15:0] memData_out;
   wire [15:0] data_out0;
   wire [15:0] data_out1;
   wire cacheEn, comp, valid_in, valid0, valid1, dirty0, dirty1, hit0, hit1;
   wire cacheWrite0, cacheWrite;
   wire [3:0] busy;
   wire memStall;
   wire memWrite;
   wire memRead;
   wire [4:0] tag_out0;
   wire [4:0] tag_out1;
   wire [15:0] memAddr;
   wire memErr, cacheErr0, cacheErr1;
   wire tagSel;
   wire offsetSel;
   wire [2:0] mem_offset;
   wire [2:0] con_offset;
   wire [2:0] offset;
   wire [4:0] tag;
   wire [15:0] cacheDataIn;
   wire cacheStall, cacheDataSel;
   wire cacheSel;
   wire victim;
   wire next_victim;
   wire [15:0] dataOut_ff;
   wire [15:0] dataIn_ff;
   wire miss_rd;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out0),
                          .data_out             (data_out0),
                          .hit                  (hit0),
                          .dirty                (dirty0),
                          .valid                (valid0),
                          .err                  (cacheErr0),
                          // Inputs
                          .enable               (cacheEn),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset),
                          .data_in              (cacheDataIn),
                          .comp                 (comp),
                          .write                (cacheWrite0),
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out1),
                          .data_out             (data_out1),
                          .hit                  (hit1),
                          .dirty                (dirty1),
                          .valid                (valid1),
                          .err                  (cacheErr1),
                          // Inputs
                          .enable               (cacheEn),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset),
                          .data_in              (cacheDataIn),
                          .comp                 (comp),
                          .write                (cacheWrite1),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (memData_out),
                     .stall             (memStall),
                     .busy              (busy),
                     .err               (memErr),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (memAddr),
                     .data_in           (DataOut),
                     .wr                (memWrite),
                     .rd                (memRead));

    cache_control con(
		     //inputs
		     .clk						(clk),
		     .rst						(rst),
		     .cacheEn					(cacheEn),
		     .valid0					(valid0),
		     .valid1					(valid1),
 		     .dirty0					(dirty0),
		     .dirty1					(dirty1),
      		 .busy						(busy),
		     .write						(Wr),
		     .hit0						(hit0),
			 .hit1						(hit1),
		     .victim					(~victim),			//send inverted victim so that victim = 1 in the first instruction
			 .flush						(flush),
			 .b_hazard					(b_hazard),
			 .offsetIn					(Addr[2:0]),
		     //outputs
		     .comp						(comp),
			 .miss_rd					(miss_rd),
		     .Done						(Done),
		     .memWrite					(memWrite),
		     .memRead					(memRead),
		     .mem_offset				(mem_offset),
		     .offset					(con_offset),
		     .cacheWrite				(cacheWrite),
		     .valid_in					(valid_in),
		     .offsetSel					(offsetSel),
		     .tagSel					(tagSel),
		     .stall						(cacheStall),
	   	     .real_hit					(CacheHit),
		     .cacheDataSel				(cacheDataSel),
		     .cacheSel					(cacheSel));	//cacheSel = 0 when select cache0
		     
   
   // your code here
   assign cacheEn = (Rd | Wr) & ~rst;
   assign err = (cacheErr0 | cacheErr1 | memErr) & ~rst;
   assign tag = tagSel ? Addr[15:11] : (cacheSel ? tag_out1 : tag_out0);
   assign memAddr = {tag, Addr[10:3], mem_offset};
   assign offset = offsetSel ? Addr[2:0] : con_offset;
   assign cacheDataIn = cacheDataSel ? DataIn : memData_out;
   assign Stall = cacheStall | memStall;

   dff victimway(.clk(clk), .rst(rst), .d(next_victim), .q(victim));
   assign next_victim = Done ? ~victim : victim;
   assign cacheWrite0 = cacheWrite & ~cacheSel;
   assign cacheWrite1 = cacheWrite & cacheSel;

   //miss_rd is asserted when it's in read data from four-bank memory stage
   //latch the data from memory when offset matches, so that don't need to read from cache
   //if the offset is 3'b110, select dataOut_ff will be too late (need the value immediately). 
   //In this case, select memData_out for output
   assign DataOut = miss_rd ? ((Addr[2:0] == 3'b110) ? memData_out : dataOut_ff) : 
   							  (cacheSel ? data_out1 : data_out0);
   assign dataIn_ff = (offset == Addr[2:0]) & miss_rd ? memData_out : dataOut_ff;
   dff dataOut [15:0] (.q(dataOut_ff), .d(dataIn_ff), .clk(clk), .rst(rst));
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
