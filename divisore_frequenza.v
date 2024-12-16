module divisore_frequenza (clk_in,reset, clock_out);  
output clock_out;
input clk_in,reset;
parameter dimension = 1;
reg [dimension-1:0] out=0;

//arechitettura

always @ (posedge clk_in, negedge reset)
    if(~reset)
        out <=0;
    else
	    if(out==(2**dimension)-1)
		    out <=0;
	    else
		    out <= out +1'b1;

assign clock_out = out[dimension-1];

endmodule