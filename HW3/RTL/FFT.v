///////////////////////////////////////////////////////////////////////////////////////
// Company: NCKU EE
// Engineer: Hua Yun Wang
// 
// Create Date: 2025/04/23
// Design Name: DIC Lab3
// Module Name: FFT
// =================================================================================//
// 2025/04/23: stage 1 cnt 0~7 correct / cnt 8~15 need to check W and fix point MUL
// 2025/04/24: stage 1~4 correct but need more bitwidth to cal 
// 2025/05/02: optimize cal remove fsm
//////////////////////////////////////////////////////////////////////////////////////


module  FFT(
    input           clk      , 
    input           rst      , 
    input  [15:0]   fir_d    , 
    input           fir_valid,
    output reg          fft_valid, 
    output reg          done     ,
    output reg [15:0]   fft_d1   , 
    output reg [15:0]   fft_d2   ,
    output reg [15:0]   fft_d3   , 
    output reg [15:0]   fft_d4   , 
    output reg [15:0]   fft_d5   , 
    output reg [15:0]   fft_d6   , 
    output reg [15:0]   fft_d7   , 
    output reg [15:0]   fft_d8   ,
    output reg [15:0]   fft_d9   , 
    output reg [15:0]   fft_d10  , 
    output reg [15:0]   fft_d11  , 
    output reg [15:0]   fft_d12  , 
    output reg [15:0]   fft_d13  , 
    output reg [15:0]   fft_d14  , 
    output reg [15:0]   fft_d15  , 
    output reg [15:0]   fft_d0
);


//============================CNT================================//
reg [3:0] cnt;
reg first_round_done, out_round;

always @(posedge clk or posedge rst) begin
    if (rst) cnt <= 4'd0;
    else begin
        if (fir_valid)
            cnt <= cnt + 4'd1;
        else begin
            if (out_round) begin
                cnt <= cnt + 4'd1;
            end
            else begin
                cnt <= cnt;
            end
        end
    end
end


always @(posedge clk or posedge rst) begin
    if (rst) begin
        first_round_done <= 1'b0;
        out_round <= 1'b0;
    end
    else begin

        if (cnt == 4'd15) first_round_done <= 1'b1;
        else first_round_done <= first_round_done;

        if (first_round_done) out_round <= 1'b1;
        else out_round <= out_round;
    end
end


//============================StoP================================//
integer i;

reg [15:0] buffer [0:15];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) buffer[i] <= 16'b0;
    end
    else begin
        if (fir_valid) begin
            buffer[cnt] <= fir_d;
        end
        else begin
            for (i = 0; i < 16; i = i + 1) buffer[i] <= buffer[i];
        end
    end
end

//=========================OUTPUT==============================//
//stage 4 reg
wire [31:0] fft_re_s4 [0:15];
wire [31:0] fft_im_s4 [0:15];

reg [15:0] buffer_re_s4  [0:15];
reg [15:0] buffer_im_s4  [0:15];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s4[i] <= 16'd0;
        for (i = 0; i < 16; i = i + 1) buffer_im_s4[i] <= 16'd0;
    end
    else begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s4[i] <= fft_re_s4[i][23:8];
        for (i = 0; i < 16; i = i + 1) buffer_im_s4[i] <= fft_im_s4[i][23:8];
    end
end

//data
always @(*) begin
    if (out_round) begin
        if (cnt == 4'd4) begin
            fft_d0  = buffer_re_s4[0] ;
            fft_d1  = buffer_re_s4[8] ;
            fft_d2  = buffer_re_s4[4] ;
            fft_d3  = buffer_re_s4[12];
            fft_d4  = buffer_re_s4[2] ;
            fft_d5  = buffer_re_s4[10];
            fft_d6  = buffer_re_s4[6] ;
            fft_d7  = buffer_re_s4[14];
            fft_d8  = buffer_re_s4[1] ;
            fft_d9  = buffer_re_s4[9] ;
            fft_d10 = buffer_re_s4[5] ;
            fft_d11 = buffer_re_s4[13];
            fft_d12 = buffer_re_s4[3] ;
            fft_d13 = buffer_re_s4[11];
            fft_d14 = buffer_re_s4[7] ;
            fft_d15 = buffer_re_s4[15];

            fft_valid   = 1'd1;
        end
        else if (cnt == 4'd5) begin
            fft_d0  = buffer_im_s4[0];
            fft_d1  = buffer_im_s4[8];
            fft_d2  = buffer_im_s4[4];
            fft_d3  = buffer_im_s4[12];
            fft_d4  = buffer_im_s4[2];
            fft_d5  = buffer_im_s4[10];
            fft_d6  = buffer_im_s4[6];
            fft_d7  = buffer_im_s4[14];
            fft_d8  = buffer_im_s4[1];
            fft_d9  = buffer_im_s4[9];
            fft_d10 = buffer_im_s4[5];
            fft_d11 = buffer_im_s4[13];
            fft_d12 = buffer_im_s4[3];
            fft_d13 = buffer_im_s4[11];
            fft_d14 = buffer_im_s4[7];
            fft_d15 = buffer_im_s4[15];

            fft_valid   = 1'd1;
        end
        else begin
            fft_d0  = 16'd0;
            fft_d1  = 16'd0;
            fft_d2  = 16'd0;
            fft_d3  = 16'd0;
            fft_d4  = 16'd0;
            fft_d5  = 16'd0;
            fft_d6  = 16'd0;
            fft_d7  = 16'd0;
            fft_d8  = 16'd0;
            fft_d9  = 16'd0;
            fft_d10 = 16'd0;
            fft_d11 = 16'd0;
            fft_d12 = 16'd0;
            fft_d13 = 16'd0;
            fft_d14 = 16'd0;
            fft_d15 = 16'd0;

            fft_valid   = 1'd0;
        end
    end
    else begin
        fft_d0  = 16'd0;
        fft_d1  = 16'd0;
        fft_d2  = 16'd0;
        fft_d3  = 16'd0;
        fft_d4  = 16'd0;
        fft_d5  = 16'd0;
        fft_d6  = 16'd0;
        fft_d7  = 16'd0;
        fft_d8  = 16'd0;
        fft_d9  = 16'd0;
        fft_d10 = 16'd0;
        fft_d11 = 16'd0;
        fft_d12 = 16'd0;
        fft_d13 = 16'd0;
        fft_d14 = 16'd0;
        fft_d15 = 16'd0;

        fft_valid   = 1'd0;
    end
end

//done
always @(*) begin
    if (fir_valid) begin
        done = 1'b0;
    end
    else begin
        if (cnt == 4'd6) done = 1'b1;
        else done = 1'b0;
    end
end

//=========================STAGE 1==============================//
wire [31:0] fft_re_s1 [0:15];
wire [31:0] fft_im_s1 [0:15];

butterfly_w0 s1_0(
    .a({buffer[0],8'd0}),
    .b(24'd0),
    .c({buffer[8],8'd0}),
    .d(24'd0),
    .ffta_re(fft_re_s1[0]),
    .ffta_im(fft_im_s1[0]),
    .fftb_re(fft_re_s1[8]),
    .fftb_im(fft_im_s1[8])
);

butterfly s1_1(
    .a({buffer[1],8'd0}),
    .b(24'd0),
    .c({buffer[9],8'd0}),
    .d(24'd0),
    .W_re(24'h00EC83),
    .W_im(24'hFF9E09),
    .ffta_re(fft_re_s1[1]),
    .ffta_im(fft_im_s1[1]),
    .fftb_re(fft_re_s1[9]),
    .fftb_im(fft_im_s1[9])
);

butterfly s1_2(
    .a({buffer[2],8'd0}),
    .b(24'd0),
    .c({buffer[10],8'd0}),
    .d(24'd0),
    .W_re(24'h00B504),
    .W_im(24'hFF4AFC),
    .ffta_re(fft_re_s1[2]),
    .ffta_im(fft_im_s1[2]),
    .fftb_re(fft_re_s1[10]),
    .fftb_im(fft_im_s1[10])
);

butterfly s1_3(
    .a({buffer[3],8'd0}),
    .b(24'd0),
    .c({buffer[11],8'd0}),
    .d(24'd0),
    .W_re(24'h0061F7),
    .W_im(24'hFF137D),
    .ffta_re(fft_re_s1[3]),
    .ffta_im(fft_im_s1[3]),
    .fftb_re(fft_re_s1[11]),
    .fftb_im(fft_im_s1[11])
);

butterfly_w4 s1_4(
    .a({buffer[4],8'd0}),
    .b(24'd0),
    .c({buffer[12],8'd0}),
    .d(24'd0),
    .ffta_re(fft_re_s1[4]),
    .ffta_im(fft_im_s1[4]),
    .fftb_re(fft_re_s1[12]),
    .fftb_im(fft_im_s1[12])
);

butterfly s1_5(
    .a({buffer[5],8'd0}),
    .b(24'd0),
    .c({buffer[13],8'd0}),
    .d(24'd0),
    .W_re(24'hFF9E09),
    .W_im(24'hFF137D),
    .ffta_re(fft_re_s1[5]),
    .ffta_im(fft_im_s1[5]),
    .fftb_re(fft_re_s1[13]),
    .fftb_im(fft_im_s1[13])
);

butterfly s1_6(
    .a({buffer[6],8'd0}),
    .b(24'd0),
    .c({buffer[14],8'd0}),
    .d(24'd0),
    .W_re(24'hFF4AFC),
    .W_im(24'hFF4AFC),
    .ffta_re(fft_re_s1[6]),
    .ffta_im(fft_im_s1[6]),
    .fftb_re(fft_re_s1[14]),
    .fftb_im(fft_im_s1[14])
);

butterfly s1_7(
    .a({buffer[7],8'd0}),
    .b(24'd0),
    .c({buffer[15],8'd0}),
    .d(24'd0),
    .W_re(24'hFF137D),
    .W_im(24'hFF9E09),
    .ffta_re(fft_re_s1[7]),
    .ffta_im(fft_im_s1[7]),
    .fftb_re(fft_re_s1[15]),
    .fftb_im(fft_im_s1[15])
);

//stage 1 reg
reg [23:0] buffer_re_s1  [0:15];
reg [23:0] buffer_im_s1  [0:15];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s1[i] <= 23'd0;
        for (i = 0; i < 16; i = i + 1) buffer_im_s1[i] <= 23'd0;
    end
    else begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s1[i] <= fft_re_s1[i][23:0];
        for (i = 0; i < 16; i = i + 1) buffer_im_s1[i] <= fft_im_s1[i][23:0];
    end
end


//=========================STAGE 2==============================//
wire [31:0] fft_re_s2 [0:15];
wire [31:0] fft_im_s2 [0:15];

butterfly_w0 s2_0(
    .a(buffer_re_s1[0]),
    .b(buffer_im_s1[0]),
    .c(buffer_re_s1[4]),
    .d(buffer_im_s1[4]),
    .ffta_re(fft_re_s2[0]),
    .ffta_im(fft_im_s2[0]),
    .fftb_re(fft_re_s2[4]),
    .fftb_im(fft_im_s2[4])
);

butterfly s2_1(
    .a(buffer_re_s1[1]),
    .b(buffer_im_s1[1]),
    .c(buffer_re_s1[5]),
    .d(buffer_im_s1[5]),
    .W_re(24'h00B504),
    .W_im(24'hFF4AFC),
    .ffta_re(fft_re_s2[1]),
    .ffta_im(fft_im_s2[1]),
    .fftb_re(fft_re_s2[5]),
    .fftb_im(fft_im_s2[5])
);

butterfly_w4 s2_2(
    .a(buffer_re_s1[2]),
    .b(buffer_im_s1[2]),
    .c(buffer_re_s1[6]),
    .d(buffer_im_s1[6]),
    .ffta_re(fft_re_s2[2]),
    .ffta_im(fft_im_s2[2]),
    .fftb_re(fft_re_s2[6]),
    .fftb_im(fft_im_s2[6])
);

butterfly s2_3(
    .a(buffer_re_s1[3]),
    .b(buffer_im_s1[3]),
    .c(buffer_re_s1[7]),
    .d(buffer_im_s1[7]),
    .W_re(24'hFF4AFC),
    .W_im(24'hFF4AFC),
    .ffta_re(fft_re_s2[3]),
    .ffta_im(fft_im_s2[3]),
    .fftb_re(fft_re_s2[7]),
    .fftb_im(fft_im_s2[7])
);

butterfly_w0 s2_4(
    .a(buffer_re_s1[8]),
    .b(buffer_im_s1[8]),
    .c(buffer_re_s1[12]),
    .d(buffer_im_s1[12]),
    .ffta_re(fft_re_s2[8]),
    .ffta_im(fft_im_s2[8]),
    .fftb_re(fft_re_s2[12]),
    .fftb_im(fft_im_s2[12])
);

butterfly s2_5(
    .a(buffer_re_s1[9]),
    .b(buffer_im_s1[9]),
    .c(buffer_re_s1[13]),
    .d(buffer_im_s1[13]),
    .W_re(24'h00B504),
    .W_im(24'hFF4AFC),
    .ffta_re(fft_re_s2[9]),
    .ffta_im(fft_im_s2[9]),
    .fftb_re(fft_re_s2[13]),
    .fftb_im(fft_im_s2[13])
);

butterfly_w4 s2_6(
    .a(buffer_re_s1[10]),
    .b(buffer_im_s1[10]),
    .c(buffer_re_s1[14]),
    .d(buffer_im_s1[14]),
    .ffta_re(fft_re_s2[10]),
    .ffta_im(fft_im_s2[10]),
    .fftb_re(fft_re_s2[14]),
    .fftb_im(fft_im_s2[14])
);

butterfly s2_7(
    .a(buffer_re_s1[11]),
    .b(buffer_im_s1[11]),
    .c(buffer_re_s1[15]),
    .d(buffer_im_s1[15]),
    .W_re(24'hFF4AFC),
    .W_im(24'hFF4AFC),
    .ffta_re(fft_re_s2[11]),
    .ffta_im(fft_im_s2[11]),
    .fftb_re(fft_re_s2[15]),
    .fftb_im(fft_im_s2[15])
);

//stage 2 reg
reg [23:0] buffer_re_s2  [0:15];
reg [23:0] buffer_im_s2  [0:15];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s2[i] <= 23'd0;
        for (i = 0; i < 16; i = i + 1) buffer_im_s2[i] <= 23'd0;
    end
    else begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s2[i] <= fft_re_s2[i][23:0];
        for (i = 0; i < 16; i = i + 1) buffer_im_s2[i] <= fft_im_s2[i][23:0];
    end
end


//=========================STAGE 3==============================//
wire [31:0] fft_re_s3 [0:15];
wire [31:0] fft_im_s3 [0:15];

butterfly_w0 s3_0(
    .a(buffer_re_s2[0]),
    .b(buffer_im_s2[0]),
    .c(buffer_re_s2[2]),
    .d(buffer_im_s2[2]),
    .ffta_re(fft_re_s3[0]),
    .ffta_im(fft_im_s3[0]),
    .fftb_re(fft_re_s3[2]),
    .fftb_im(fft_im_s3[2])
);

butterfly_w4 s3_1(
    .a(buffer_re_s2[1]),
    .b(buffer_im_s2[1]),
    .c(buffer_re_s2[3]),
    .d(buffer_im_s2[3]),
    .ffta_re(fft_re_s3[1]),
    .ffta_im(fft_im_s3[1]),
    .fftb_re(fft_re_s3[3]),
    .fftb_im(fft_im_s3[3])
);

butterfly_w0 s3_2(
    .a(buffer_re_s2[4]),
    .b(buffer_im_s2[4]),
    .c(buffer_re_s2[6]),
    .d(buffer_im_s2[6]),
    .ffta_re(fft_re_s3[4]),
    .ffta_im(fft_im_s3[4]),
    .fftb_re(fft_re_s3[6]),
    .fftb_im(fft_im_s3[6])
);

butterfly_w4 s3_3(
    .a(buffer_re_s2[5]),
    .b(buffer_im_s2[5]),
    .c(buffer_re_s2[7]),
    .d(buffer_im_s2[7]),
    .ffta_re(fft_re_s3[5]),
    .ffta_im(fft_im_s3[5]),
    .fftb_re(fft_re_s3[7]),
    .fftb_im(fft_im_s3[7])
);

butterfly_w0 s3_4(
    .a(buffer_re_s2[8]),
    .b(buffer_im_s2[8]),
    .c(buffer_re_s2[10]),
    .d(buffer_im_s2[10]),
    .ffta_re(fft_re_s3[8]),
    .ffta_im(fft_im_s3[8]),
    .fftb_re(fft_re_s3[10]),
    .fftb_im(fft_im_s3[10])
);

butterfly_w4 s3_5(
    .a(buffer_re_s2[9]),
    .b(buffer_im_s2[9]),
    .c(buffer_re_s2[11]),
    .d(buffer_im_s2[11]),
    .ffta_re(fft_re_s3[9]),
    .ffta_im(fft_im_s3[9]),
    .fftb_re(fft_re_s3[11]),
    .fftb_im(fft_im_s3[11])
);

butterfly_w0 s3_6(
    .a(buffer_re_s2[12]),
    .b(buffer_im_s2[12]),
    .c(buffer_re_s2[14]),
    .d(buffer_im_s2[14]),
    .ffta_re(fft_re_s3[12]),
    .ffta_im(fft_im_s3[12]),
    .fftb_re(fft_re_s3[14]),
    .fftb_im(fft_im_s3[14])
);

butterfly_w4 s3_7(
    .a(buffer_re_s2[13]),
    .b(buffer_im_s2[13]),
    .c(buffer_re_s2[15]),
    .d(buffer_im_s2[15]),
    .ffta_re(fft_re_s3[13]),
    .ffta_im(fft_im_s3[13]),
    .fftb_re(fft_re_s3[15]),
    .fftb_im(fft_im_s3[15])
);

//stage 3 reg
reg [23:0] buffer_re_s3  [0:15];
reg [23:0] buffer_im_s3  [0:15];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s3[i] <= 23'd0;
        for (i = 0; i < 16; i = i + 1) buffer_im_s3[i] <= 23'd0;
    end
    else begin
        for (i = 0; i < 16; i = i + 1) buffer_re_s3[i] <= fft_re_s3[i][23:0];
        for (i = 0; i < 16; i = i + 1) buffer_im_s3[i] <= fft_im_s3[i][23:0];
    end
end

//=========================STAGE 4==============================//
butterfly_w0 s4_0(
    .a(buffer_re_s3[0]),
    .b(buffer_im_s3[0]),
    .c(buffer_re_s3[1]),
    .d(buffer_im_s3[1]),
    .ffta_re(fft_re_s4[0]),
    .ffta_im(fft_im_s4[0]),
    .fftb_re(fft_re_s4[1]),
    .fftb_im(fft_im_s4[1])
);

butterfly_w0 s4_1(
    .a(buffer_re_s3[2]),
    .b(buffer_im_s3[2]),
    .c(buffer_re_s3[3]),
    .d(buffer_im_s3[3]),
    .ffta_re(fft_re_s4[2]),
    .ffta_im(fft_im_s4[2]),
    .fftb_re(fft_re_s4[3]),
    .fftb_im(fft_im_s4[3])
);

butterfly_w0 s4_2(
    .a(buffer_re_s3[4]),
    .b(buffer_im_s3[4]),
    .c(buffer_re_s3[5]),
    .d(buffer_im_s3[5]),
    .ffta_re(fft_re_s4[4]),
    .ffta_im(fft_im_s4[4]),
    .fftb_re(fft_re_s4[5]),
    .fftb_im(fft_im_s4[5])
);

butterfly_w0 s4_3(
    .a(buffer_re_s3[6]),
    .b(buffer_im_s3[6]),
    .c(buffer_re_s3[7]),
    .d(buffer_im_s3[7]),
    .ffta_re(fft_re_s4[6]),
    .ffta_im(fft_im_s4[6]),
    .fftb_re(fft_re_s4[7]),
    .fftb_im(fft_im_s4[7])
);

butterfly_w0 s4_4(
    .a(buffer_re_s3[8]),
    .b(buffer_im_s3[8]),
    .c(buffer_re_s3[9]),
    .d(buffer_im_s3[9]),
    .ffta_re(fft_re_s4[8]),
    .ffta_im(fft_im_s4[8]),
    .fftb_re(fft_re_s4[9]),
    .fftb_im(fft_im_s4[9])
);

butterfly_w0 s4_5(
    .a(buffer_re_s3[10]),
    .b(buffer_im_s3[10]),
    .c(buffer_re_s3[11]),
    .d(buffer_im_s3[11]),
    .ffta_re(fft_re_s4[10]),
    .ffta_im(fft_im_s4[10]),
    .fftb_re(fft_re_s4[11]),
    .fftb_im(fft_im_s4[11])
);

butterfly_w0 s4_6(
    .a(buffer_re_s3[12]),
    .b(buffer_im_s3[12]),
    .c(buffer_re_s3[13]),
    .d(buffer_im_s3[13]),
    .ffta_re(fft_re_s4[12]),
    .ffta_im(fft_im_s4[12]),
    .fftb_re(fft_re_s4[13]),
    .fftb_im(fft_im_s4[13])
);

butterfly_w0 s4_7(
    .a(buffer_re_s3[14]),
    .b(buffer_im_s3[14]),
    .c(buffer_re_s3[15]),
    .d(buffer_im_s3[15]),
    .ffta_re(fft_re_s4[14]),
    .ffta_im(fft_im_s4[14]),
    .fftb_re(fft_re_s4[15]),
    .fftb_im(fft_im_s4[15])
);

endmodule

module butterfly(
    input [23:0] a,
    input [23:0] b,
    input [23:0] c,
    input [23:0] d,
    input [23:0] W_re,
    input [23:0] W_im,
    output [31:0] ffta_re,
    output [31:0] ffta_im,
    output [31:0] fftb_re,
    output [31:0] fftb_im
);

    //fft_a
    assign ffta_re = $signed({{8{a[23]}}, a}) + $signed({{8{c[23]}}, c});
    assign ffta_im = $signed({{8{b[23]}}, b}) + $signed({{8{d[23]}}, d});

    //fft_b
    wire [23:0] a_c;
    wire [23:0] b_d;

    assign a_c = $signed(a) - $signed(c);
    assign b_d = $signed(b) - $signed(d);

    wire [47:0] fft_re_t, fft_im_t;

    assign fft_re_t = $signed(a_c) * $signed(W_re) - $signed(b_d) * $signed(W_im);
    assign fft_im_t = $signed(a_c) * $signed(W_im) + $signed(b_d) * $signed(W_re);

    assign fftb_re = fft_re_t[47:16];
    assign fftb_im = fft_im_t[47:16];

endmodule

module butterfly_w0(
    input [23:0] a,
    input [23:0] b,
    input [23:0] c,
    input [23:0] d,
    output [31:0] ffta_re,
    output [31:0] ffta_im,
    output [31:0] fftb_re,
    output [31:0] fftb_im
);

    //fft_a
    assign ffta_re = $signed({{8{a[23]}}, a}) + $signed({{8{c[23]}}, c});
    assign ffta_im = $signed({{8{b[23]}}, b}) + $signed({{8{d[23]}}, d});

    //fft_b
    wire [23:0] a_c;
    wire [23:0] b_d;

    assign a_c = $signed(a) - $signed(c);
    assign b_d = $signed(b) - $signed(d);

    wire [47:0] fft_re_t, fft_im_t;

    assign fft_re_t = $signed(a_c) << 16;
    assign fft_im_t = $signed(b_d) << 16;

    assign fftb_re = fft_re_t[47:16];
    assign fftb_im = fft_im_t[47:16];

endmodule

module butterfly_w4(
    input [23:0] a,
    input [23:0] b,
    input [23:0] c,
    input [23:0] d,
    output [31:0] ffta_re,
    output [31:0] ffta_im,
    output [31:0] fftb_re,
    output [31:0] fftb_im
);

    //fft_a
    assign ffta_re = $signed({{8{a[23]}}, a}) + $signed({{8{c[23]}}, c});
    assign ffta_im = $signed({{8{b[23]}}, b}) + $signed({{8{d[23]}}, d});

    //fft_b
    wire [23:0] a_c;
    wire [23:0] b_d;

    assign a_c = $signed(a) - $signed(c);
    assign b_d = $signed(b) - $signed(d);

    wire [47:0] fft_re_t, fft_im_t;

    assign fft_re_t = ($signed(b_d) << 16);
    assign fft_im_t = - ($signed(a_c) << 16);

    assign fftb_re = fft_re_t[47:16];
    assign fftb_im = fft_im_t[47:16];

endmodule