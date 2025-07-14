module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////
wire [3:0] C1_min, C1_max;
wire [3:0] C2_min, C2_max;

Comparator2 C1(
    .A  (num1),  
    .B  (num2),  
    .min(C1_min),  
    .max(C1_max)  
);

Comparator2 C2(
    .A  (C1_max),  
    .B  (num3),  
    .min(C2_min),  
    .max()  
);

Comparator2 C3(
    .A  (C1_min),  
    .B  (C2_min),  
    .min(),  
    .max(median)  
);

endmodule
