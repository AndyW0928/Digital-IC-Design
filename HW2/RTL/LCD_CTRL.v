module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	output reg		  IROM_rd  , 
	output reg [5:0] IROM_A   ,
	output reg		  IRAM_ceb ,
	output reg		  IRAM_web ,
	output reg [7:0] IRAM_D   ,
	output reg [5:0] IRAM_A   ,
	input 	[7:0] IRAM_Q   ,
	output reg		  busy	   ,
	output reg		  done
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

reg [7:0] buffer [0:63];

reg [2:0] state, nstate;

parameter IDLE = 3'd0,
		  READ = 3'd1,
		  WAIT_CMD = 3'd2,
		  ALU = 3'd3,
		  WRITE_BACK = 3'd4;

reg [5:0] addr_mem;

reg read_end, write_end; 

//ALU
reg write_en;
reg alu_en;
reg [7:0] alu_in0, alu_in1, alu_in2, alu_in3, alu_in4, alu_in5, alu_in6, alu_in7, alu_in8, alu_in9, alu_in10, alu_in11, alu_in12, alu_in13, alu_in14, alu_in15;
reg [7:0] alu_out;
reg [5:0] alu_addr, alu_addr_r;


//===========================================================================//
//================================FSM========================================//
//===========================================================================//

//cs
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= IDLE;
	end
	else begin
		state <= nstate;
	end
end

//ns
always @(*) begin
	case (state)
	IDLE : nstate = READ;
	READ : begin
			if (read_end) nstate = WAIT_CMD;
			else nstate = READ;
	end
	WAIT_CMD : begin
				if (cmd_valid) nstate = ALU;
			   	else nstate = WAIT_CMD;
	end
	ALU : begin
		   if (write_en) nstate = WRITE_BACK;
		   else nstate = WAIT_CMD;
	end
	WRITE_BACK : begin
		   if (write_end) nstate = WAIT_CMD;
		   else nstate = WRITE_BACK;
	end
	default : nstate = IDLE;
	endcase
end

//out
always @(*) begin
	case(state)
	IDLE : begin
		//output
			IROM_rd  = 1'b0;
			IROM_A   = 6'b0; 
			IRAM_ceb = 1'b0;
			IRAM_web = 1'b0;
			IRAM_D   = 8'b0;
			IRAM_A   = 6'b0;
			busy     = 1'b1;
			done     = 1'b0;

		//to ALU
			alu_en   = 1'b0;

			alu_in0  = 8'b0;
			alu_in1  = 8'b0;
			alu_in2  = 8'b0;
			alu_in3  = 8'b0;
			alu_in4  = 8'b0;
			alu_in5  = 8'b0;
			alu_in6  = 8'b0;
			alu_in7  = 8'b0;
			alu_in8  = 8'b0;
			alu_in9  = 8'b0;
			alu_in10 = 8'b0;
			alu_in11 = 8'b0;
			alu_in12 = 8'b0;
			alu_in13 = 8'b0;
			alu_in14 = 8'b0;
			alu_in15 = 8'b0;


	end
	READ : begin
		//output
			IROM_rd  = 1'b1;
			IROM_A   = addr_mem; 
			IRAM_ceb = 1'b0;
			IRAM_web = 1'b0;
			IRAM_D   = 8'b0;
			IRAM_A   = 6'b0;
			busy     = 1'b1;
			done     = 1'b0;

		//to ALU
			alu_en   = 1'b0;

			alu_in0  = 8'b0;
			alu_in1  = 8'b0;
			alu_in2  = 8'b0;
			alu_in3  = 8'b0;
			alu_in4  = 8'b0;
			alu_in5  = 8'b0;
			alu_in6  = 8'b0;
			alu_in7  = 8'b0;
			alu_in8  = 8'b0;
			alu_in9  = 8'b0;
			alu_in10 = 8'b0;
			alu_in11 = 8'b0;
			alu_in12 = 8'b0;
			alu_in13 = 8'b0;
			alu_in14 = 8'b0;
			alu_in15 = 8'b0;

	end 
	WAIT_CMD : begin
		//output
			IROM_rd  = 1'b0;
			IROM_A   = 6'b0; 
			IRAM_ceb = 1'b0;
			IRAM_web = 1'b0;
			IRAM_D   = 8'b0;
			IRAM_A   = 6'b0;
			busy     = 1'b0;
			done     = 1'b0;

		//to ALU
			alu_en   = 1'b0;

			alu_in0  = buffer[alu_addr_r];
			alu_in1  = buffer[alu_addr_r + 6'd1];
			alu_in2  = buffer[alu_addr_r + 6'd2];
			alu_in3  = buffer[alu_addr_r + 6'd3];
			alu_in4  = buffer[alu_addr_r + 6'd8];
			alu_in5  = buffer[alu_addr_r + 6'd9];
			alu_in6  = buffer[alu_addr_r + 6'd10];
			alu_in7  = buffer[alu_addr_r + 6'd11];
			alu_in8  = buffer[alu_addr_r + 6'd16];
			alu_in9  = buffer[alu_addr_r + 6'd17];
			alu_in10 = buffer[alu_addr_r + 6'd18];
			alu_in11 = buffer[alu_addr_r + 6'd19];
			alu_in12 = buffer[alu_addr_r + 6'd24];
			alu_in13 = buffer[alu_addr_r + 6'd25];
			alu_in14 = buffer[alu_addr_r + 6'd26];
			alu_in15 = buffer[alu_addr_r + 6'd27];
	end
	ALU : begin
		//output
			IROM_rd  = 1'b0;
			IROM_A   = 6'b0; 
			IRAM_ceb = 1'b0;
			IRAM_web = 1'b0;
			IRAM_D   = 8'b0;
			IRAM_A   = 6'b0;
			busy     = 1'b1;
			done     = 1'b0;

		//to ALU
			alu_en   = 1'b1;

			alu_in0  = buffer[alu_addr_r];
			alu_in1  = buffer[alu_addr_r + 6'd1];
			alu_in2  = buffer[alu_addr_r + 6'd2];
			alu_in3  = buffer[alu_addr_r + 6'd3];
			alu_in4  = buffer[alu_addr_r + 6'd8];
			alu_in5  = buffer[alu_addr_r + 6'd9];
			alu_in6  = buffer[alu_addr_r + 6'd10];
			alu_in7  = buffer[alu_addr_r + 6'd11];
			alu_in8  = buffer[alu_addr_r + 6'd16];
			alu_in9  = buffer[alu_addr_r + 6'd17];
			alu_in10 = buffer[alu_addr_r + 6'd18];
			alu_in11 = buffer[alu_addr_r + 6'd19];
			alu_in12 = buffer[alu_addr_r + 6'd24];
			alu_in13 = buffer[alu_addr_r + 6'd25];
			alu_in14 = buffer[alu_addr_r + 6'd26];
			alu_in15 = buffer[alu_addr_r + 6'd27];
	end
	WRITE_BACK : begin
		//output
			IROM_rd  = 1'b1;
			IROM_A   = 6'b0; 
			IRAM_ceb = 1'b1;
			IRAM_web = 1'b0;
			IRAM_D   = buffer[addr_mem];
			IRAM_A   = addr_mem;
			busy     = ~write_end;
			done     = write_end;

		//to ALU
			alu_en   = 1'b0;

			alu_in0  = 8'b0;
			alu_in1  = 8'b0;
			alu_in2  = 8'b0;
			alu_in3  = 8'b0;
			alu_in4  = 8'b0;
			alu_in5  = 8'b0;
			alu_in6  = 8'b0;
			alu_in7  = 8'b0;
			alu_in8  = 8'b0;
			alu_in9  = 8'b0;
			alu_in10 = 8'b0;
			alu_in11 = 8'b0;
			alu_in12 = 8'b0;
			alu_in13 = 8'b0;
			alu_in14 = 8'b0;
			alu_in15 = 8'b0;

	end 
	default :  begin
		//output
			IROM_rd  = 1'b0;
			IROM_A   = 6'b0; 
			IRAM_ceb = 1'b0;
			IRAM_web = 1'b0;
			IRAM_D   = 8'b0;
			IRAM_A   = 6'b0;
			busy     = 1'b0;
			done     = 1'b0;

		//to ALU
			alu_en   = 1'b0;

			alu_in0  = 8'b0;
			alu_in1  = 8'b0;
			alu_in2  = 8'b0;
			alu_in3  = 8'b0;
			alu_in4  = 8'b0;
			alu_in5  = 8'b0;
			alu_in6  = 8'b0;
			alu_in7  = 8'b0;
			alu_in8  = 8'b0;
			alu_in9  = 8'b0;
			alu_in10 = 8'b0;
			alu_in11 = 8'b0;
			alu_in12 = 8'b0;
			alu_in13 = 8'b0;
			alu_in14 = 8'b0;
			alu_in15 = 8'b0;
	end
	endcase
end

//===========================================================================//
//================================ALU========================================//
//===========================================================================//
reg [8:0] max1, max2, max3, max4, max5, max6, max7, max8, max9, max10, max11, max12, max13, max14;
reg [8:0] min1, min2, min3, min4, min5, min6, min7, min8, min9, min10, min11, min12, min13, min14;
reg [11:0] avg_add;

//ALU
always @(*) begin
	if (alu_en) begin
		case (cmd)
		4'd0 : begin
				write_en = 1'b1;
				alu_addr = 6'b0;
				alu_out	= 8'b0;
		end
		4'd1 : begin
				write_en = 1'b0;
			    alu_addr = alu_addr_r - 6'd8;  
				alu_out	= 8'b0;
		end 
		4'd2 : begin
				write_en = 1'b0;
				alu_addr = alu_addr_r + 6'd8; 
				alu_out = 8'b0;
		end
		4'd3 : begin
				write_en = 1'b0;
				alu_addr = alu_addr_r - 6'd1; 
				alu_out = 8'b0;
		end
		4'd4 : begin
				write_en = 1'b0;
				alu_addr = alu_addr_r + 6'd1; 
				alu_out = 8'b0;
		end
		4'd5 : begin
				//level1
				max1 = (alu_in0 > alu_in1)? alu_in0 : alu_in1;
				max2 = (alu_in2 > alu_in3)? alu_in2 : alu_in3;
				max3 = (alu_in4 > alu_in5)? alu_in4 : alu_in5;
				max4 = (alu_in6 > alu_in7)? alu_in6 : alu_in7;
				max5 = (alu_in8 > alu_in9)? alu_in8 : alu_in9;
				max6 = (alu_in10 > alu_in11)? alu_in10 : alu_in11;
				max7 = (alu_in12 > alu_in13)? alu_in12 : alu_in13;
				max8 = (alu_in14 > alu_in15)? alu_in14 : alu_in15;

				//level2
				max9 = (max1 > max2)? max1 : max2;
				max10 = (max3 > max4)? max3 : max4;
				max11 = (max5 > max6)? max5 : max6;
				max12 = (max7 > max8)? max7 : max8;

				//level3
				max13 = (max9 > max10)? max9 : max10;
				max14 = (max11 > max12)? max11 : max12;

				//level4
				alu_out = (max13 > max14)? max13 : max14;

				write_en = 1'b0;
				alu_addr = 6'b0;
		end
		4'd6 : begin
				//level1
				min1 = (alu_in0 < alu_in1)? alu_in0 : alu_in1;
				min2 = (alu_in2 < alu_in3)? alu_in2 : alu_in3;
				min3 = (alu_in4 < alu_in5)? alu_in4 : alu_in5;
				min4 = (alu_in6 < alu_in7)? alu_in6 : alu_in7;
				min5 = (alu_in8 < alu_in9)? alu_in8 : alu_in9;
				min6 = (alu_in10 < alu_in11)? alu_in10 : alu_in11;
				min7 = (alu_in12 < alu_in13)? alu_in12 : alu_in13;
				min8 = (alu_in14 < alu_in15)? alu_in14 : alu_in15;

				//level2
				min9 = (min1 < min2)? min1 : min2;
				min10 = (min3 <  min4)? min3 : min4;
				min11 = (min5 <  min6)? min5 : min6;
				min12 = (min7 <  min8)? min7 : min8;

				//level3
				min13 = (min9 < min10)? min9 : min10;
				min14 = (min11 < min12)? min11 : min12;

				//level4
				alu_out = (min13 < min14)? min13 : min14;

				write_en = 1'b0;
				alu_addr = 6'b0;
		end
		4'd7 : begin
				avg_add = alu_in0 + alu_in1 + alu_in2 + alu_in3 + alu_in4 + alu_in5 + alu_in6 + alu_in7 + alu_in8 + alu_in9 + alu_in10 + alu_in11 + alu_in12 + alu_in13 + alu_in14 + alu_in15;
				alu_out = avg_add >> 4 ;
				write_en = 1'b0;
				alu_addr = 6'b0;
		end
		endcase
	end
	else begin

	end
end

//===========================================================================//
//================================BUF========================================//
//===========================================================================//
//reg
//buffer
integer i;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for(i = 0; i < 64; i = i + 1) buffer[i] <= 8'b0;
	end
	else begin
		case(state)
		IDLE : for(i = 0; i < 64; i = i + 1) buffer[i] <= buffer[i];
		READ : buffer[addr_mem] <= IROM_Q;
		ALU : begin
				case (cmd)
				4'd5, 4'd6, 4'd7: begin
									buffer[alu_addr_r]			<= alu_out;
									buffer[alu_addr_r + 6'd1]	<= alu_out;
									buffer[alu_addr_r + 6'd2]	<= alu_out;
									buffer[alu_addr_r + 6'd3]	<= alu_out;
									buffer[alu_addr_r + 6'd8]	<= alu_out;
									buffer[alu_addr_r + 6'd9]	<= alu_out;
									buffer[alu_addr_r + 6'd10]	<= alu_out;
									buffer[alu_addr_r + 6'd11]	<= alu_out;
									buffer[alu_addr_r + 6'd16]	<= alu_out;
									buffer[alu_addr_r + 6'd17]	<= alu_out;
									buffer[alu_addr_r + 6'd18]	<= alu_out;
									buffer[alu_addr_r + 6'd19]	<= alu_out;
									buffer[alu_addr_r + 6'd24]	<= alu_out;
									buffer[alu_addr_r + 6'd25]	<= alu_out;
									buffer[alu_addr_r + 6'd26]	<= alu_out;
									buffer[alu_addr_r + 6'd27]	<= alu_out;
				end
				default : for(i = 0; i < 64; i = i + 1) buffer[i] <= buffer[i];
				endcase
		end
		default : for(i = 0; i < 64; i = i + 1) buffer[i] <= buffer[i];
		endcase
	end
end

//alu_addr_r
always @(posedge clk or posedge rst) begin
	if (rst) begin
		alu_addr_r <= 6'h12;
	end
	else begin
		if (alu_en) begin
			case (cmd)
			4'd1, 4'd2, 4'd3, 4'd4 : begin
									 if (alu_addr > 6'h24) alu_addr_r <= alu_addr_r;
									 else alu_addr_r <= alu_addr;
			end
			default : alu_addr_r <= alu_addr_r;
			endcase
		end
		else alu_addr_r <= alu_addr_r;
	end
end


//contr
//read
always @(posedge clk or posedge rst) begin
	if (rst) begin
		addr_mem <= 6'b0;
		read_end <= 1'b0;
		write_end <= 1'b0;
	end
	else begin
		if (addr_mem == 6'd63) begin
			addr_mem <= 6'd0;
			read_end <= 1'b1;
			write_end <= 1'b1;
		end
		else begin
			case (state)
			READ : begin
					addr_mem <= addr_mem + 6'd1;
					read_end <= 1'b0;
					write_end <= 1'b0;
			end
			WAIT_CMD : begin
					addr_mem <= 6'b0;
					read_end <= 1'b0;
					write_end <= 1'b0;
			end
			WRITE_BACK : begin
					addr_mem <= addr_mem + 6'd1;
					read_end <= 1'b0;
					write_end <= 1'b0;
			end
			default : begin
				addr_mem <= addr_mem;
				read_end <= 1'b0;
				write_end <= 1'b0;
			end
			endcase
		end
	end
end



endmodule