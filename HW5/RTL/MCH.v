///////////////////////////////////////////////////////////////////////////////////////
// Company: NCKU EE
// Engineer: Hua Yun Wang
// 
// Create Date: 2025/06/18
// Design Name: DIC Lab5
// Module Name: MCH
// =================================================================================//
// 2025/6/18 : polar == 0 wrong
// 2025/6/19 : pass
//////////////////////////////////////////////////////////////////////////////////////



module MCH (
    input               clk,
    input               reset,
    input       [ 7:0]  X,
    input       [ 7:0]  Y,
    output reg          Done,
    output reg  [16:0]  area
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////
//FSM
reg [3:0] state, nstate;
parameter LOAD = 4'd0,
          ANCH = 4'd1,
          SORT = 4'd2,
          CAL = 4'd3,
          CAL_AREA = 4'd4,
          OUT = 4'd5;

//buffer
integer i;
reg [15:0] buffer [0:19];
reg [4:0] index;                //A
reg [4:0] index2;               //B
reg [4:0] index_base;               //sub index
reg [4:0] anchor_index_reg;

//cal
wire signed [8:0] x_sub;             //A
wire signed [8:0] y_sub;             //A
wire signed [8:0] x_sub2;            //B
wire signed [8:0] y_sub2;            //B
wire signed [16:0] mul_1, mul_2;
wire signed [16:0] polar;
wire signed [16:0] area_A, area_B;
wire signed [17:0] area_sub;
reg signed [17:0] area_o;



always @(posedge clk or posedge reset) begin
    if (reset) begin
        //buffer
        for (i = 0; i <20 ; i = i + 1) buffer[i] <= 16'b0;
        //index
        index <= 5'b0;
        index2 <= 5'b0;
        index_base <= 5'd0;
    end
    else begin
        if (index == 5'd20) begin
            //buffer
            for (i = 0; i < 20 ; i = i + 1) buffer[i] <= buffer[i];
            //index
            index <= 5'd0;
            index2 <= 5'd0;
            index_base <= 5'd0;
        end
        else begin
            if (state == LOAD) begin
                //buffer
                buffer[index] <= {X,Y};
                //index
                index <= index + 5'd1;
                index2 <= 5'd0;
                index_base <= 5'd0;
            end
            else if (state == ANCH) begin
                //buffer
                buffer[index] <= buffer[anchor_index_reg];
                buffer[anchor_index_reg] <= buffer[index];
                //index
                index <= index + 5'd1;
                index2 <= 5'd2;
                index_base <= 5'd0;
            end
            else if (state == SORT) begin
                //buffer
                if (polar[16] == 1'b1) begin
                    buffer[index] <= buffer[index2];
                    buffer[index2] <= buffer[index];
                end
                else if (polar == 17'b0) begin
                    if (buffer[index][15:8] < buffer[index2][15:8]) begin
                        buffer[index] <= buffer[index2];
                        buffer[index2] <= buffer[index];
                    end
                    else if (buffer[index][7:0] < buffer[index2][7:0]) begin
                        buffer[index] <= buffer[index2];
                        buffer[index2] <= buffer[index];
                    end
                    else begin
                        for (i = 0; i < 20 ; i = i + 1) buffer[i] <= buffer[i];
                    end
                end
                else begin
                    for (i = 0; i < 20 ; i = i + 1) buffer[i] <= buffer[i];
                end

                //index
                if (index2 == 5'd19) begin
                    if (index == 5'd18) begin
                        index <= 5'd1;
                        index2 <= 5'd2;
                        index_base <= 5'd0;
                    end
                    else begin
                        index <= index + 5'd1;
                        index2 <= index + 5'd2;
                        index_base <= 5'd0;
                    end
                end
                else begin
                    index <= index;
                    index2 <= index2 + 5'd1;
                    index_base <= 5'd0;
                end
            end
            else if (state == CAL) begin
                //buffer
                buffer[index_base + 5'd2] <= buffer[index2];
                //index
                if (polar[16] == 1'b0)begin
                    if (index2 == 5'd19) begin
                        index_base <= index_base + 5'd2;
                        index <= 5'd0;
                        index2 <= 5'd1;
                    end
                    else if (x_sub == 9'd0 && y_sub == 9'd0) begin
                        index_base <= index_base - 5'd1;
                        index <= index - 5'd1;
                        index2 <= index2;
                    end
                    else begin
                        index_base <= index_base + 5'd1;
                        index <= index + 5'd1;
                        index2 <= index2 + 5'd1;
                    end
                end
                else if (polar[16] == 1'b1) begin
                    index_base <= index_base - 5'd1;
                    index <= index - 5'd1;
                    index2 <= index2;
                end

            end
            else if (state == CAL_AREA) begin
                for (i = 0; i < 20 ; i = i + 1) buffer[i] <= buffer[i];
                if (index2 == index_base) begin
                    index <= index + 5'd1;
                    index2 <= 5'd0;
                    index_base <= index_base; 
                end
                else begin
                    index <= index + 5'd1;
                    index2 <= index2 + 5'd1;
                    index_base <= index_base;   
                end  
            end
            else begin
                for (i = 0; i < 20 ; i = i + 1) buffer[i] <= buffer[i];
                index <= 5'd0;
                index2 <= 5'd0;
                index_base <= 5'd0;
            end
        end
    end
end


//anchor
// reg [15:0] anchor;              //X[15:8] Y[7:0]

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // anchor <= 16'b0;
        anchor_index_reg <= 5'd0;
    end
    else begin
        if (state == LOAD) begin
            if (index == 5'b0) begin
                // anchor <= {X,Y};
                anchor_index_reg <= 5'd0;
            end
            else begin
                if (Y < buffer[anchor_index_reg][7:0]) begin
                    // anchor <= {X,Y};
                    anchor_index_reg <= index;
                end
                else if ((Y == buffer[anchor_index_reg][7:0]) && X < buffer[anchor_index_reg][15:8]) begin
                    // anchor <= {X,Y};
                    anchor_index_reg <= index;
                end
                else begin
                    // anchor <= anchor;
                    anchor_index_reg <= anchor_index_reg;
                end
            end
        end
        else begin
            // anchor <= anchor;
            anchor_index_reg <= 5'd0;
        end
    end
end

//polar
assign x_sub = $signed({1'b0,buffer[index][15:8]}) - $signed({1'b0,buffer[index_base][15:8]}); 
assign y_sub = $signed({1'b0,buffer[index][7:0]})  - $signed({1'b0,buffer[index_base][7:0]}); 

assign x_sub2 = $signed({1'b0,buffer[index2][15:8]}) - $signed({1'b0,buffer[index_base][15:8]});
assign y_sub2 = $signed({1'b0,buffer[index2][7:0]})  - $signed({1'b0,buffer[index_base][7:0]});
assign mul_1 = x_sub * y_sub2;
assign mul_2 = y_sub * x_sub2;

assign polar = $signed(mul_1) - $signed(mul_2);

//area
assign area_A =  buffer[index][15:8] * buffer[index2][7:0];
assign area_B =  buffer[index2][15:8] * buffer[index][7:0];
assign area_sub = $signed(area_A) - $signed(area_B);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        area_o <= 18'b0;
    end
    else begin
        if (state == CAL_AREA) area_o <= area_o + area_sub;
        else area_o <= 18'b0;
    end
end


//FSM

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= LOAD;
    end
    else begin
        state <= nstate;
    end
end

always @(*) begin
    case(state)
    LOAD : nstate = (index == 5'd20)? ANCH : LOAD;
    ANCH : nstate = SORT;
    SORT : nstate = (index == 5'd18 && index2 == 5'd19)? CAL : SORT;
    CAL : nstate = (index2 == 5'd19 && polar[16] == 1'b0)? CAL_AREA : CAL;
    CAL_AREA : nstate = (index2 == 5'd0)? OUT : CAL_AREA;
    OUT : nstate = LOAD;
    endcase
end

always @(*) begin
    case(state)
    LOAD : begin
            Done = 1'b0;
            area = 17'b0;
    end
    ANCH : begin
            Done = 1'b0;
            area = 17'b0;
    end
    SORT : begin
            Done = 1'b0;
            area = 17'b0;
    end
    CAL : begin
            Done = 1'b0;
            area = 17'b0;
    end
    CAL_AREA : begin
            Done = 1'b0;
            area = 17'b0;
    end
    OUT : begin
            Done = 1'd1;
            area = area_o[16:0];
    end
    endcase
end

endmodule