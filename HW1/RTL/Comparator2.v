module Comparator2 (
    input   [3:0]   A  ,  
    input   [3:0]   B  ,  
    output  [3:0]   min,  
    output  [3:0]   max  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////
assign mux_sel = (A <= B);

//mux_min
assign min = (mux_sel)? A : B; 

//mux_max
assign max = (mux_sel)? B : A;

endmodule
