module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////
wire [3:0] C1_1_min, C1_1_max;
wire [3:0] C1_2_min, C1_2_max;
wire [3:0] C1_3_min, C1_3_max;

wire [3:0] C2_1_min, C2_1_max;
wire [3:0] C2_2_min, C2_2_max;

wire [3:0] C3max_min, C3min_max;



//1 2
Comparator2 C1_1(
    .A  (num1),  
    .B  (num2),  
    .min(C1_1_min),  
    .max(C1_1_max)  
);

//3 4
Comparator2 C1_2(
    .A  (num3),  
    .B  (num4),  
    .min(C1_2_min),  
    .max(C1_2_max)  
);

//5 6
Comparator2 C1_3(
    .A  (num5),  
    .B  (num6),  
    .min(C1_3_min),  
    .max(C1_3_max)  
);


Comparator2 C2_max(
    .A  (C1_1_max),  
    .B  (C1_2_max),  
    .min(C2_1_min),   //need
    .max(C2_1_max)  
);

Comparator2 C2_min(
    .A  (C1_1_min),  
    .B  (C1_2_min),  
    .min(C2_2_min),   //need
    .max(C2_2_max)  	
);	 

//max
Comparator2 C3_max(
    .A  (C1_3_max),  
    .B  (C2_1_max),  
    .min(C3max_min),   //need
    .max()  
);

//min
Comparator2 C3_min(
    .A  (C1_3_min),  
    .B  (C2_2_min),  
    .min(),  
    .max(C3min_max)    //need
);

MedianFinder_5num MedianFinder_5num(
    .num1  (num7), 
	.num2  (C2_1_min), 
	.num3  (C2_2_max), 
	.num4  (C3max_min), 
	.num5  (C3min_max),  
    .median(median)  
);


endmodule
