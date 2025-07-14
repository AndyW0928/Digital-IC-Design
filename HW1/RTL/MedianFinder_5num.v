module MedianFinder_5num(
    input  [3:0] 	num1  , 
	input  [3:0] 	num2  , 
	input  [3:0] 	num3  , 
	input  [3:0] 	num4  , 
	input  [3:0] 	num5  ,  
    output [3:0] 	median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////
wire [3:0] C1_1_min, C1_1_max;
wire [3:0] C1_2_min, C1_2_max;
wire [3:0] C2_1_min, C2_1_max;
wire [3:0] C2_2_min, C2_2_max;

Comparator2 C1_1(
    .A  (num1),  
    .B  (num2),  
    .min(C1_1_min),  
    .max(C1_1_max)  
);

Comparator2 C1_2(
    .A  (num3),  
    .B  (num4),  
    .min(C1_2_min),  
    .max(C1_2_max)  
);

Comparator2 C2_1(
    .A  (C1_1_min),  
    .B  (C1_2_min),  
    .min(),  
    .max(C2_1_max)  
);

Comparator2 C2_2(
    .A  (C1_1_max),  
    .B  (C1_2_max),  
    .min(C2_2_min),  
    .max()  
);

MedianFinder_3num MedianFinder_3num(
    .num1  (C2_1_max), 
    .num2  (C2_2_min), 
    .num3  (num5),  
    .median(median)
);


endmodule
