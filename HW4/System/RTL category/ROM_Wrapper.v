`timescale 1ns/10ps
`include "./include/define.v"

module ROM_Wrapper(
	input     						bus_clk ,
	input     						bus_rst ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input     						RVALID_S,
	output 	reg   [`BUS_DATA_BITS-1:0] RDATA_S ,
	output 	reg   						RLAST_S ,	//
	output 	reg  						RREADY_S,
	output 	reg						ROM_rd  ,
	output  reg   [`BUS_ADDR_BITS-1:0] ROM_A  	,
	input 	   [`BUS_DATA_BITS-1:0] ROM_Q 
);
	/////////////////////////////////
	// Please write your code here //
	/////////////////////////////////

	always @(*) begin
		RREADY_S = 1'd1;
		ROM_rd	 = RVALID_S;
		RDATA_S  = ROM_Q;
		ROM_A	 = ADDR_S;
	end


	
	
endmodule

