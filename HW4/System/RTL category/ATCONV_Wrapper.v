`timescale 1ns/10ps
`include "./include/define.v"

module ATCONV_Wrapper(
    input		                        bus_clk  ,
    input		                        bus_rst  ,
    input         [`BUS_DATA_BITS-1:0]          RDATA_M  ,
    input 	      				RLAST_M  ,
    input 	      				WREADY_M ,
    input 	      				RREADY_M ,
    output  reg     [`BUS_ID_BITS  -1:0]          ID_M	 ,
    output  reg     [`BUS_ADDR_BITS-1:0]          ADDR_M	 ,
    output  reg     [`BUS_DATA_BITS-1:0]          WDATA_M  ,
    output  reg     [`BUS_LEN_BITS -1:0]          BLEN_M   ,
    output  reg					WLAST_M  ,
    output  reg					WVALID_M ,
    output  reg					RVALID_M ,
    output  wire                                   done   
);

        /////////////////////////////////
	// Please write your code here //
	/////////////////////////////////

        //ROM
        wire            ROM_rd     ;
        wire   [11:0]	iaddr      ;    //64x64
        reg   [15:0]	idata      ;

        //S1
        wire            layer0_ceb ;     
        wire            layer0_web ;     //H:read L:write
        wire   [11:0]   layer0_A   ;
        wire   [15:0]   layer0_D   ;     
        reg   [15:0]   layer0_Q   ;

        //S2
        wire            layer1_ceb ;
        wire            layer1_web ;
        wire   [11:0]   layer1_A   ;
        wire   [15:0]   layer1_D   ;
        wire   [15:0]   layer1_Q   ;


        always @(*) begin
                ID_M	  = (ROM_rd)? 2'd0 : (layer0_ceb)? 2'd1 : (layer1_ceb)? 2'd2 : 2'd0;
                ADDR_M	  = (ROM_rd)? iaddr : (layer0_ceb)? layer0_A : (layer1_ceb)? layer1_A : 12'd0;
                WDATA_M   = (layer0_ceb)? layer0_D : (layer1_ceb)? layer1_D : 16'd0;
                BLEN_M    = 4'd0;
                WLAST_M   = 1'd0;
                WVALID_M  = ((layer0_ceb & ~layer0_web) || (layer1_ceb & ~layer1_web));
                RVALID_M  = (ROM_rd || (layer0_ceb & layer0_web));
        end


        always @(*) begin
                if (RVALID_M && RREADY_M) begin
                        if (ROM_rd) begin
                                idata = RDATA_M;
                                layer0_Q = 16'd0;
                        end
                        else if ((layer0_ceb & layer0_web)) begin
                                idata = 16'd0;
                                layer0_Q = RDATA_M;
                        end
                        else if ((layer1_ceb & layer1_web)) begin
                                idata = 16'd0;
                                layer0_Q = RDATA_M;
                        end 
                        else begin
                                idata = 16'd0;
                                layer0_Q = 16'd0;
                        end
                end
                else begin
                        idata = 16'd0;
                        layer0_Q = 16'd0;
                end 
        end


        

        ATCONV ATCONV (
                .clk       (bus_clk),
                .rst       (bus_rst),

                //ROM
                .ROM_rd    (ROM_rd),
                .iaddr     (iaddr),     //64x64
                .idata     (idata),

                //S1
                .layer0_ceb(layer0_ceb),     
                .layer0_web(layer0_web),     //H:read L:write
                .layer0_A  (layer0_A),
                .layer0_D  (layer0_D),     
                .layer0_Q  (layer0_Q),

                //S2
                .layer1_ceb(layer1_ceb),
                .layer1_web(layer1_web),
                .layer1_A  (layer1_A),
                .layer1_D  (layer1_D),
                .layer1_Q  (layer1_Q),

                //finish
                .done(done)        
        );



endmodule



module  ATCONV(
        input		clk       ,
        input		rst       ,

        //ROM
        output reg          ROM_rd    ,
        output reg [11:0]	iaddr     ,     //64x64
        input  [15:0]	idata     ,

        //S1
        output reg          layer0_ceb,     
        output reg          layer0_web,     //H:read L:write
        output reg [11:0]   layer0_A  ,
        output reg [15:0]   layer0_D  ,     
        input  [15:0]   layer0_Q  ,

        //S2
        output reg          layer1_ceb,
        output reg          layer1_web,
        output reg [11:0]   layer1_A  ,
        output reg [15:0]   layer1_D  ,
        input  [15:0]   layer1_Q  ,

        //finish
        output reg          done        
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////
reg [1:0] state, nstate;
parameter IDLE = 2'd0,
          LAYER0 = 2'd1,
          LAYER1 = 2'd2;
          
//===========================================================================================//
//========================================CNT================================================//
//===========================================================================================//

reg [5:0] addr_x, addr_y;
reg [3:0] cnt;
reg [11:0] addr_s2;

//center address
always @(posedge clk or posedge rst) begin
        if (rst) begin
                addr_x <= 6'd0;
                addr_y <= 6'd0;
                cnt <= 4'd0;
                addr_s2 <= 12'd0;
        end
        else begin
                case (state)
                IDLE, LAYER0: begin
                        if (cnt == 4'd9) begin   
                                cnt <= 4'd0;

                                addr_x <= addr_x + 6'd1;
                                
                                if (addr_x == 6'd63) addr_y <= addr_y + 6'd1;
                                else addr_y <= addr_y;

                                addr_s2 <= addr_s2;
                        end
                        else begin
                                cnt <= cnt + 4'd1;
                                addr_x <= addr_x;
                                addr_y <= addr_y;
                                addr_s2 <= addr_s2;
                        end
                end
                LAYER1 : begin
                        if (cnt == 4'd4) begin   
                                cnt <= 4'd0;

                                addr_x <= addr_x + 6'd2;
                                
                                if (addr_x == 6'd62) addr_y <= addr_y + 6'd2;
                                else addr_y <= addr_y;

                                addr_s2 <= addr_s2 + 12'd1;
                        end
                        else begin
                                cnt <= cnt + 4'd1;
                                addr_x <= addr_x;
                                addr_y <= addr_y;
                                addr_s2 <= addr_s2;
                        end
                end
                endcase
        end
end


//===========================================================================================//
//=======================================ADDR================================================//
//===========================================================================================//


//read address
reg [11:0] addr_rom;
wire [5:0] addr_y_a2, addr_y_m2;
wire [5:0] addr_x_a2, addr_x_m2;

assign addr_y_a2 = addr_y + 6'd2;
assign addr_y_m2 = addr_y - 6'd2;
assign addr_x_a2 = addr_x + 6'd2;
assign addr_x_m2 = addr_x - 6'd2;

always @(*) begin
        if (addr_x < 6'd2 && addr_y < 6'd2) begin                       //up-left corner
                case (cnt)
                4'd0 : addr_rom = 12'd0;
                4'd1 : addr_rom = {6'd0, addr_x};
                4'd2 : addr_rom = {6'd0, addr_x_a2};
                4'd3 : addr_rom = {addr_y, 6'd0};
                4'd4 : addr_rom = {addr_y, addr_x};
                4'd5 : addr_rom = {addr_y, addr_x_a2};
                4'd6 : addr_rom = {addr_y_a2, 6'd0};
                4'd7 : addr_rom = {addr_y_a2, addr_x};
                4'd8 : addr_rom = {addr_y_a2, addr_x_a2};
                default : addr_rom = 12'd0;
                endcase
        end
        else if (addr_x > 6'd61 && addr_y < 6'd2) begin                 //up-right corner
                case (cnt)
                4'd0 : addr_rom = {6'd0, addr_x_m2};
                4'd1 : addr_rom = {6'd0, addr_x};
                4'd2 : addr_rom = 12'd63;
                4'd3 : addr_rom = {addr_y, addr_x_m2};
                4'd4 : addr_rom = {addr_y, addr_x};
                4'd5 : addr_rom = {addr_y, 6'd63};
                4'd6 : addr_rom = {addr_y_a2, addr_x_m2};
                4'd7 : addr_rom = {addr_y_a2, addr_x};
                4'd8 : addr_rom = {addr_y_a2, 6'd63};
                default : addr_rom = 12'd0;
                endcase
        end
        else if (addr_x < 6'd2 && addr_y > 6'd61) begin                 //down-left corner
                case (cnt)
                4'd0 : addr_rom = {addr_y_m2, 6'd0};
                4'd1 : addr_rom = {addr_y_m2, addr_x};
                4'd2 : addr_rom = {addr_y_m2, addr_x_a2};
                4'd3 : addr_rom = {addr_y, 6'd0};
                4'd4 : addr_rom = {addr_y, addr_x};
                4'd5 : addr_rom = {addr_y, addr_x_a2};
                4'd6 : addr_rom = {6'd63, 6'd0};
                4'd7 : addr_rom = {6'd63, addr_x};
                4'd8 : addr_rom = {6'd63, addr_x_a2};
                default : addr_rom = 12'd0;
                endcase
        end
        else if (addr_x > 6'd61 && addr_y > 6'd61) begin                 //down-right corner
                case (cnt)
                4'd0 : addr_rom = {addr_y_m2, addr_x_m2};
                4'd1 : addr_rom = {addr_y_m2, addr_x};
                4'd2 : addr_rom = {addr_y_m2, 6'd63};
                4'd3 : addr_rom = {addr_y, addr_x_m2};
                4'd4 : addr_rom = {addr_y, addr_x};
                4'd5 : addr_rom = {addr_y, 6'd63};
                4'd6 : addr_rom = {6'd63, addr_x_m2};
                4'd7 : addr_rom = {6'd63, addr_x};
                4'd8 : addr_rom = {6'd63, 6'd63};
                default : addr_rom = 12'd0;
                endcase
        end
        else begin
                if (addr_y < 6'd2) begin                                //up
                        case (cnt)
                        4'd0 : addr_rom = {6'd0, addr_x_m2};
                        4'd1 : addr_rom = {6'd0, addr_x};
                        4'd2 : addr_rom = {6'd0, addr_x_a2};
                        4'd3 : addr_rom = {addr_y, addr_x_m2};
                        4'd4 : addr_rom = {addr_y, addr_x};
                        4'd5 : addr_rom = {addr_y, addr_x_a2};
                        4'd6 : addr_rom = {addr_y_a2, addr_x_m2};
                        4'd7 : addr_rom = {addr_y_a2, addr_x};
                        4'd8 : addr_rom = {addr_y_a2, addr_x_a2};
                        default : addr_rom = 12'd0;
                        endcase
                end
                else if (addr_y > 6'd61) begin                          //down
                        case (cnt)
                        4'd0 : addr_rom = {addr_y_m2, addr_x_m2};
                        4'd1 : addr_rom = {addr_y_m2, addr_x};
                        4'd2 : addr_rom = {addr_y_m2, addr_x_a2};
                        4'd3 : addr_rom = {addr_y, addr_x_m2};
                        4'd4 : addr_rom = {addr_y, addr_x};
                        4'd5 : addr_rom = {addr_y, addr_x_a2};
                        4'd6 : addr_rom = {6'd63, addr_x_m2};
                        4'd7 : addr_rom = {6'd63, addr_x};
                        4'd8 : addr_rom = {6'd63, addr_x_a2};
                        default : addr_rom = 12'd0;
                        endcase
                end
                else if (addr_x < 6'd2) begin                           //left
                        case (cnt)
                        4'd0 : addr_rom = {addr_y_m2, 6'd0};
                        4'd1 : addr_rom = {addr_y_m2, addr_x};
                        4'd2 : addr_rom = {addr_y_m2, addr_x_a2};
                        4'd3 : addr_rom = {addr_y, 6'd0};
                        4'd4 : addr_rom = {addr_y, addr_x};
                        4'd5 : addr_rom = {addr_y, addr_x_a2};
                        4'd6 : addr_rom = {addr_y_a2, 6'd0};
                        4'd7 : addr_rom = {addr_y_a2, addr_x};
                        4'd8 : addr_rom = {addr_y_a2, addr_x_a2};
                        default : addr_rom = 12'd0;
                        endcase
                end
                else if (addr_x > 6'd61) begin                          //right
                        case (cnt)
                        4'd0 : addr_rom = {addr_y_m2, addr_x_m2};
                        4'd1 : addr_rom = {addr_y_m2, addr_x};
                        4'd2 : addr_rom = {addr_y_m2, 6'd63};
                        4'd3 : addr_rom = {addr_y, addr_x_m2};
                        4'd4 : addr_rom = {addr_y, addr_x};
                        4'd5 : addr_rom = {addr_y, 6'd63};
                        4'd6 : addr_rom = {addr_y_a2, addr_x_m2};
                        4'd7 : addr_rom = {addr_y_a2, addr_x};
                        4'd8 : addr_rom = {addr_y_a2, 6'd63};
                        default : addr_rom = 12'd0;
                        endcase
                end
                else begin
                        case (cnt)
                        4'd0 : addr_rom = {addr_y_m2, addr_x_m2};
                        4'd1 : addr_rom = {addr_y_m2, addr_x};
                        4'd2 : addr_rom = {addr_y_m2, addr_x_a2};
                        4'd3 : addr_rom = {addr_y, addr_x_m2};
                        4'd4 : addr_rom = {addr_y, addr_x};
                        4'd5 : addr_rom = {addr_y, addr_x_a2};
                        4'd6 : addr_rom = {addr_y_a2, addr_x_m2};
                        4'd7 : addr_rom = {addr_y_a2, addr_x};
                        4'd8 : addr_rom = {addr_y_a2, addr_x_a2};
                        default : addr_rom = 12'd0;
                        endcase
                end
        end
end

reg [11:0] addr_sram;

always @(*) begin
        case (cnt)
        4'd0 : addr_sram = {addr_y, addr_x};
        4'd1 : addr_sram = {addr_y, addr_x + 6'd1};
        4'd2 : addr_sram = {addr_y + 6'd1, addr_x};
        4'd3 : addr_sram = {addr_y + 6'd1, addr_x + 6'd1};
        4'd4 : addr_sram = addr_s2;
        default : addr_sram = 12'd0;
        endcase
end  
                
//===========================================================================================//
//========================================CAL================================================//
//===========================================================================================//
reg signed [15:0] psum, psum_r, psum_out;

always @(*) begin
        case (cnt)
        4'd0, 4'd2, 4'd6, 4'd8: psum = -($signed(idata)) >>> 4;
        4'd1, 4'd7: psum = -($signed(idata)) >>> 3;
        4'd3, 4'd5 : psum = -($signed(idata)) >>> 2;
        4'd4 : psum = $signed(idata);
        default : psum = 16'd0;
        endcase
end

always @(posedge clk or posedge rst) begin
        if (rst) begin
                psum_r <= 16'd0;
        end
        else begin
                if (cnt == 4'd0) psum_r <= psum;
                else psum_r <= psum + psum_r;
        end
end

always @(*) begin
        psum_out = psum_r + 16'hFFF4;
end

//===========================================================================================//
//========================================MAX================================================//
//===========================================================================================//
reg [15:0] max;

always @(posedge clk or posedge rst) begin
        if (rst) max <= 16'd0;
        else begin
                case (state)
                IDLE, LAYER0 : max <= 16'd0;
                LAYER1 : begin
                        if (cnt == 4'd0) max <= layer0_Q;
                        else max <= (layer0_Q > max)? layer0_Q : max;
                end
                endcase
        end
end
                


//===========================================================================================//
//========================================FSM================================================//
//===========================================================================================//

//cs
always @(posedge clk or posedge rst) begin
        if (rst) begin
                state <= 2'd0;
        end
        else begin
                state <= nstate;
        end
end

//ns
always @(*) begin
        case(state)
        IDLE : nstate = LAYER0;
        LAYER0 : nstate = (({addr_y,addr_x} == 64'b0) && (cnt == 4'd0))? LAYER1 : LAYER0;
        LAYER1 : nstate = LAYER1;
        default : nstate = IDLE;
        endcase
end

//out
always @(*) begin
        case (state)
        IDLE : begin
                ROM_rd = 1'd1;
                iaddr  = 12'd0;

                layer0_ceb = 1'd0;
                layer0_web = 1'd0;
                layer0_A   = 12'd0;
                layer0_D   = 16'd0;

                layer1_ceb = 1'd0;
                layer1_web = 1'd0;
                layer1_A   = 12'd0;
                layer1_D   = 16'd0;

                done       = 1'd0;
        end
        LAYER0 : begin
                ROM_rd = (cnt == 4'd9)? 1'd0 : 1'd1;
                iaddr  = addr_rom;

                layer0_ceb = (cnt == 4'd9)? 1'd1 : 1'd0;
                layer0_web = 1'd0;
                layer0_A   = {addr_y,addr_x};
                layer0_D   = (psum_out[15] == 1'b1)? 16'b0 : psum_out;

                layer1_ceb = 1'd0;
                layer1_web = 1'd0;
                layer1_A   = 12'd0;
                layer1_D   = 16'd0;

                done       = 1'd0;
        end
        LAYER1 : begin
                ROM_rd = 1'd0;
                iaddr  = 12'd0;

                layer0_ceb = (cnt == 4'd4)? 1'd0 : 1'd1;
                layer0_web = 1'd1;
                layer0_A   = addr_sram;
                layer0_D   = 16'b0;

                layer1_ceb = (cnt == 4'd4)? 1'd1 : 1'd0;
                layer1_web = 1'd0;
                layer1_A   = addr_sram;
                layer1_D   = (max[3:0] == 4'd0)? max : {max[15:4] + 12'd1, 4'd0};

                done       = (({addr_y,addr_x} == 64'b0) && (cnt== 4'b0));
        end
        default : begin
                ROM_rd = 1'd0;
                iaddr  = 12'd0;

                layer0_ceb = 1'd0;
                layer0_web = 1'd0;
                layer0_A   = 12'd0;
                layer0_D   = 16'd0;

                layer1_ceb = 1'd0;
                layer1_web = 1'd0;
                layer1_A   = 12'd0;
                layer1_D   = 16'd0;

                done       = 1'd0;
        end
        endcase
end


endmodule
