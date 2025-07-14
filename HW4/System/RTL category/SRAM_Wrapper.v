`timescale 1ns/10ps
`include "./include/define.v"

module SRAM_Wrapper(
	input 	   						bus_clk ,
	input 	   						bus_rst ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_DATA_BITS-1:0] WDATA_S ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input      						WLAST_S ,
	input      						WVALID_S,
	input      						RVALID_S,
	output  reg   [`BUS_DATA_BITS-1:0] RDATA_S ,
	output  reg   						RLAST_S ,	//
	output  reg   						WREADY_S,
	output  reg   						RREADY_S,
	output 	reg   [`BUS_DATA_BITS-1:0] SRAM_D  ,
	output 	reg   [`BUS_ADDR_BITS-1:0] SRAM_A  ,
	input	   [`BUS_DATA_BITS-1:0] SRAM_Q  ,
	output	reg						SRAM_ceb,
	output	reg						SRAM_web		
);
	/////////////////////////////////
	// Please write your code here //
	/////////////////////////////////

	always @(*) begin
		RREADY_S = 1'd1;
		WREADY_S = 1'd1;

		RDATA_S  = SRAM_Q;
		SRAM_D   = WDATA_S;
		SRAM_A   = ADDR_S;

		SRAM_ceb = (WVALID_S || RVALID_S);
		SRAM_web = (WVALID_S)? 1'b0 : 1'b1;
	end
	
endmodule
